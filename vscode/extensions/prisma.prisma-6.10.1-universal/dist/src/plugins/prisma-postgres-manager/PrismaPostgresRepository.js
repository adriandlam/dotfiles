"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PrismaPostgresRepository = exports.LocalDatabaseSchema = exports.RemoteDatabaseSchema = exports.ProjectSchema = exports.WorkspaceSchema = void 0;
exports.isWorkspace = isWorkspace;
exports.isProject = isProject;
exports.isRemoteDatabase = isRemoteDatabase;
exports.isLocalDatabase = isLocalDatabase;
const vscode_1 = require("vscode");
const client_1 = require("./management-api/client");
const credentials_store_1 = require("@prisma/credentials-store");
const zod_1 = require("zod");
const env_paths_1 = __importDefault(require("env-paths"));
const fs = __importStar(require("fs/promises"));
const path = __importStar(require("path"));
const waitForPortBorrowed_1 = require("./utils/waitForPortBorrowed");
const waitForPortAvailable_1 = require("./utils/waitForPortAvailable");
const getUniquePorts_1 = require("./utils/getUniquePorts");
const isPidRunning_1 = require("./utils/isPidRunning");
const proxy_signals_1 = require("foreground-child/proxy-signals");
const child_process_1 = require("child_process");
const PPG_DEV_GLOBAL_ROOT = (0, env_paths_1.default)('prisma-dev');
exports.WorkspaceSchema = zod_1.z.object({
    type: zod_1.z.literal('workspace'),
    id: zod_1.z.string(),
    name: zod_1.z.string(),
});
function isWorkspace(item) {
    return exports.WorkspaceSchema.safeParse(item).success;
}
exports.ProjectSchema = zod_1.z.object({
    type: zod_1.z.literal('project'),
    id: zod_1.z.string(),
    name: zod_1.z.string(),
    workspaceId: zod_1.z.string(),
});
function isProject(item) {
    return exports.ProjectSchema.safeParse(item).success;
}
exports.RemoteDatabaseSchema = zod_1.z.object({
    type: zod_1.z.literal('remoteDatabase'),
    id: zod_1.z.string(),
    name: zod_1.z.string(),
    region: zod_1.z.string().nullable(),
    projectId: zod_1.z.string(),
    workspaceId: zod_1.z.string(),
});
function isRemoteDatabase(item) {
    return exports.RemoteDatabaseSchema.safeParse(item).success;
}
exports.LocalDatabaseSchema = zod_1.z.object({
    type: zod_1.z.literal('localDatabase'),
    id: zod_1.z.string(),
    name: zod_1.z.string(),
    url: zod_1.z.string().url(),
    pid: zod_1.z.number(),
    running: zod_1.z.boolean(),
});
function isLocalDatabase(item) {
    return exports.LocalDatabaseSchema.safeParse(item).success;
}
class PrismaPostgresRepository {
    constructor(auth, connectionStringStorage, context) {
        this.auth = auth;
        this.connectionStringStorage = connectionStringStorage;
        this.context = context;
        this.clients = new Map();
        this.credentialsStore = new credentials_store_1.CredentialsStore();
        this.regionsCache = [];
        this.workspacesCache = new Map();
        this.projectsCache = new Map();
        this.remoteDatabasesCache = new Map();
        this.refreshEventEmitter = new vscode_1.EventEmitter();
    }
    getClient(workspaceId) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!this.clients.has(workspaceId)) {
                yield this.credentialsStore.reloadCredentialsFromDisk();
                const credentials = yield this.credentialsStore.getCredentialsForWorkspace(workspaceId);
                if (!credentials)
                    throw new Error(`Workspace '${workspaceId}' not found`);
                const refreshTokenHandler = () => __awaiter(this, void 0, void 0, function* () {
                    const credentials = yield this.credentialsStore.getCredentialsForWorkspace(workspaceId);
                    if (!credentials)
                        throw new Error(`Workspace '${workspaceId}' not found`);
                    const { token, refreshToken } = yield this.auth.refreshToken(credentials.refreshToken);
                    yield this.credentialsStore.storeCredentials(Object.assign(Object.assign({}, credentials), { token, refreshToken }));
                    return { token };
                });
                const client = (0, client_1.createManagementAPIClient)(credentials.token, refreshTokenHandler);
                this.clients.set(workspaceId, client);
            }
            return this.clients.get(workspaceId);
        });
    }
    checkResponseOrThrow(workspaceId, response) {
        var _a, _b, _c, _d;
        console.log('Received response', { error: response.error, statusCode: response.response.status });
        if (response.response.status < 400 && !response.error)
            return;
        if (response.response.status === 401) {
            void this.removeWorkspace({ workspaceId });
            throw new Error(`Session expired. Please sign in to continue.`);
        }
        const error = zod_1.z
            .object({
            message: zod_1.z.string().optional(),
            errorDescription: zod_1.z.string().optional(),
            error: zod_1.z
                .object({
                message: zod_1.z.string().optional(),
            })
                .optional(),
        })
            .safeParse(response.error);
        const errorMessage = ((_a = error.data) === null || _a === void 0 ? void 0 : _a.message) || ((_c = (_b = error.data) === null || _b === void 0 ? void 0 : _b.error) === null || _c === void 0 ? void 0 : _c.message) || ((_d = error.data) === null || _d === void 0 ? void 0 : _d.errorDescription);
        if (!errorMessage)
            throw new Error(`Unknown API error occurred. Status Code: ${response.response.status}.`);
        throw new Error(errorMessage);
    }
    triggerRefresh() {
        void this.credentialsStore.reloadCredentialsFromDisk();
        // Wipe caches
        this.regionsCache = [];
        this.workspacesCache = new Map();
        this.projectsCache = new Map();
        this.remoteDatabasesCache = new Map();
        // Trigger full tree view refresh which will fetch fresh data on demand due to cache misses
        this.refreshEventEmitter.fire();
    }
    getRegions() {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            if (this.regionsCache.length > 0)
                return this.regionsCache;
            const workspaceId = (_a = (yield this.getWorkspaces()).at(0)) === null || _a === void 0 ? void 0 : _a.id;
            if (!workspaceId)
                return [];
            const client = yield this.getClient(workspaceId);
            const response = yield client.GET('/regions');
            this.checkResponseOrThrow(workspaceId, response);
            this.regionsCache = response.data.data;
            return this.regionsCache;
        });
    }
    ensureValidRegion(value) {
        // This is not super precise but at the point this validation is called, the
        // regions are already in the cache.
        // Async type asserting function do not exist in typescript and we anyways have
        // a potential runtime mismatch between the actually available regions and the
        // regions known to the type system.
        if (!this.regionsCache.some((r) => r.id === value)) {
            throw new Error(`Invalid region: ${value}. Available regions: ${this.regionsCache.map((r) => r.id).join(', ')}.`);
        }
    }
    getWorkspaces() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.workspacesCache.size > 0)
                return Array.from(this.workspacesCache.values());
            const credentials = yield this.credentialsStore.getCredentials();
            const results = yield Promise.allSettled(credentials.map((cred) => __awaiter(this, void 0, void 0, function* () {
                const client = yield this.getClient(cred.workspaceId);
                const response = yield client.GET('/workspaces');
                this.checkResponseOrThrow(cred.workspaceId, response);
                const workspaceInfo = response.data.data.at(0);
                if (!workspaceInfo)
                    throw new Error(`Workspaces endpoint returned no workspace info.`);
                const workspace = {
                    type: 'workspace',
                    id: workspaceInfo.id,
                    name: workspaceInfo.displayName,
                };
                this.workspacesCache.set(workspace.id, workspace);
                return workspace;
            })));
            return results
                .flatMap((r) => {
                if (r.status === 'fulfilled') {
                    return [r.value];
                }
                else {
                    console.error(`Failed to get workspace info`, r.reason);
                    return [];
                }
            })
                .sort((a, b) => a.name.localeCompare(b.name));
        });
    }
    addWorkspace(_a) {
        return __awaiter(this, arguments, void 0, function* ({ token, refreshToken }) {
            const client = (0, client_1.createManagementAPIClient)(token, () => {
                throw new Error('Received token has to be instantly refreshed. Something is wrong.');
            });
            const response = yield client.GET('/workspaces');
            if (response.error)
                throw new Error(`Failed to retrieve workspace information.`);
            const workspaces = response.data.data;
            if (workspaces.length === 0)
                throw new Error(`Received token does not grant access to any workspaces.`);
            yield Promise.all(workspaces.map((_a) => __awaiter(this, [_a], void 0, function* ({ id, displayName }) {
                yield this.credentialsStore.storeCredentials({
                    workspaceId: id,
                    token,
                    refreshToken,
                });
                this.workspacesCache.set(id, {
                    type: 'workspace',
                    id,
                    name: displayName,
                });
            })));
            this.refreshEventEmitter.fire();
        });
    }
    removeWorkspace(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId }) {
            this.clients.delete(workspaceId);
            yield this.connectionStringStorage.removeConnectionString({ workspaceId });
            this.workspacesCache.delete(workspaceId);
            yield this.credentialsStore.deleteCredentials(workspaceId);
            this.refreshEventEmitter.fire();
            return Promise.resolve();
        });
    }
    getProjects(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId }, { forceCacheRefresh } = { forceCacheRefresh: false }) {
            if (!forceCacheRefresh) {
                const cachedProjects = this.projectsCache.get(workspaceId);
                if (cachedProjects !== undefined)
                    return Array.from(cachedProjects.values());
            }
            const client = yield this.getClient(workspaceId);
            const response = yield client.GET('/projects');
            this.checkResponseOrThrow(workspaceId, response);
            const projects = new Map(response.data.data.map((project) => [
                project.id,
                {
                    type: 'project',
                    id: project.id,
                    name: project.name,
                    workspaceId,
                },
            ]));
            this.projectsCache.set(workspaceId, projects);
            return Array.from(projects.values());
        });
    }
    createProject(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, name, region, options, }) {
            var _b;
            this.ensureValidRegion(region);
            const client = yield this.getClient(workspaceId);
            const response = yield client.POST('/projects', {
                body: {
                    name,
                    region,
                },
            });
            this.checkResponseOrThrow(workspaceId, response);
            const newProject = {
                type: 'project',
                id: response.data.id,
                name: response.data.name,
                workspaceId,
            };
            let createdDatabase;
            let connectionString;
            if ('databases' in response.data) {
                const createdDatabaseData = response.data.databases[0];
                if (createdDatabaseData) {
                    createdDatabase = {
                        type: 'remoteDatabase',
                        id: createdDatabaseData.id,
                        name: createdDatabaseData.name,
                        region: createdDatabaseData.region,
                        projectId: newProject.id,
                        workspaceId,
                    };
                    connectionString = createdDatabaseData.connectionString;
                    yield this.connectionStringStorage.storeConnectionString({
                        workspaceId,
                        projectId: newProject.id,
                        databaseId: createdDatabase.id,
                        connectionString,
                    });
                }
            }
            if (options.skipRefresh !== true) {
                // Proactively update cache
                (_b = this.projectsCache.get(workspaceId)) === null || _b === void 0 ? void 0 : _b.set(newProject.id, newProject);
                this.remoteDatabasesCache.set(`${workspaceId}.${newProject.id}`, new Map(createdDatabase ? [[createdDatabase.id, createdDatabase]] : []));
                // Update in the background
                this.refreshEventEmitter.fire();
                void this.refreshProjects({ workspaceId });
            }
            if (createdDatabase && connectionString) {
                return { project: newProject, database: Object.assign(Object.assign({}, createdDatabase), { connectionString }) };
            }
            else {
                return { project: newProject };
            }
        });
    }
    deleteProject(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, id }) {
            var _b;
            const client = yield this.getClient(workspaceId);
            const response = yield client.DELETE('/projects/{id}', {
                params: {
                    path: { id },
                },
            });
            this.checkResponseOrThrow(workspaceId, response);
            yield this.connectionStringStorage.removeConnectionString({
                workspaceId,
                projectId: id,
            });
            // Proactively update cache
            (_b = this.projectsCache.get(workspaceId)) === null || _b === void 0 ? void 0 : _b.delete(id);
            this.refreshEventEmitter.fire();
            // And then refresh list from server in background
            void this.refreshProjects({ workspaceId });
        });
    }
    refreshProjects(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId }) {
            yield this.getProjects({ workspaceId }, { forceCacheRefresh: true }).then(() => this.refreshEventEmitter.fire());
        });
    }
    getRemoteDatabases(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId, }, { forceCacheRefresh } = { forceCacheRefresh: false }) {
            if (!forceCacheRefresh) {
                const cachedDatabases = this.remoteDatabasesCache.get(`${workspaceId}.${projectId}`);
                if (cachedDatabases !== undefined)
                    return Array.from(cachedDatabases.values());
            }
            const client = yield this.getClient(workspaceId);
            const response = yield client.GET('/projects/{projectId}/databases', {
                params: {
                    path: { projectId },
                },
            });
            this.checkResponseOrThrow(workspaceId, response);
            const databases = new Map(response.data.data.map((db) => [
                db.id,
                {
                    type: 'remoteDatabase',
                    id: db.id,
                    name: db.name,
                    region: db.region,
                    projectId,
                    workspaceId,
                },
            ]));
            this.remoteDatabasesCache.set(`${workspaceId}.${projectId}`, databases);
            return Array.from(databases.values());
        });
    }
    getStoredRemoteDatabaseConnectionString(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId, databaseId, }) {
            return this.connectionStringStorage.getConnectionString({ workspaceId, projectId, databaseId });
        });
    }
    createRemoteDatabaseConnectionString(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId, databaseId, }) {
            const client = yield this.getClient(workspaceId);
            const response = yield client.POST('/projects/{projectId}/databases/{databaseId}/connections', {
                params: {
                    path: { projectId, databaseId },
                },
                body: {
                    name: "Created by Prisma's VSCode Extension",
                },
            });
            this.checkResponseOrThrow(workspaceId, response);
            const connectionString = response.data.connectionString;
            yield this.connectionStringStorage.storeConnectionString({
                workspaceId,
                projectId,
                databaseId,
                connectionString,
            });
            return connectionString;
        });
    }
    createRemoteDatabase(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId, name, region, options, }) {
            var _b;
            this.ensureValidRegion(region);
            const client = yield this.getClient(workspaceId);
            const response = yield client.POST('/projects/{projectId}/databases', {
                params: {
                    path: { projectId },
                },
                body: {
                    name,
                    region,
                },
            });
            this.checkResponseOrThrow(workspaceId, response);
            const newDatabase = {
                type: 'remoteDatabase',
                id: response.data.id,
                name: response.data.name,
                region: response.data.region,
                projectId,
                workspaceId,
            };
            const connectionString = response.data.connectionString;
            if (options.skipRefresh !== true) {
                // Proactively update cache
                (_b = this.remoteDatabasesCache.get(workspaceId)) === null || _b === void 0 ? void 0 : _b.set(newDatabase.id, newDatabase);
                // Update in the background
                this.refreshEventEmitter.fire();
                void this.refreshRemoteDatabases({ workspaceId, projectId });
            }
            yield this.connectionStringStorage.storeConnectionString({
                workspaceId,
                projectId,
                databaseId: newDatabase.id,
                connectionString,
            });
            return Object.assign(Object.assign({}, newDatabase), { connectionString });
        });
    }
    deleteRemoteDatabase(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId, id, }) {
            var _b;
            const client = yield this.getClient(workspaceId);
            const response = yield client.DELETE('/projects/{projectId}/databases/{databaseId}', {
                params: {
                    path: {
                        projectId,
                        databaseId: id,
                    },
                },
            });
            this.checkResponseOrThrow(workspaceId, response);
            yield this.connectionStringStorage.removeConnectionString({
                workspaceId,
                projectId,
                databaseId: id,
            });
            // Proactively update cache
            (_b = this.remoteDatabasesCache.get(`${workspaceId}.${projectId}`)) === null || _b === void 0 ? void 0 : _b.delete(id);
            this.refreshEventEmitter.fire();
            // And then refresh list from server in background
            void this.refreshRemoteDatabases({ workspaceId, projectId });
        });
    }
    refreshRemoteDatabases(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId }) {
            yield this.getRemoteDatabases({ workspaceId, projectId }, { forceCacheRefresh: true }).then(() => this.refreshEventEmitter.fire());
        });
    }
    refreshLocalDatabases() {
        this.refreshEventEmitter.fire();
    }
    getLocalDatabases() {
        return __awaiter(this, void 0, void 0, function* () {
            const { ServerState } = yield import('@prisma/dev/internal/state');
            return (yield ServerState.scan()).map((state) => {
                var _a, _b;
                const { name, exports, status } = state;
                const running = status === 'running';
                const url = (_a = exports === null || exports === void 0 ? void 0 : exports.ppg.url) !== null && _a !== void 0 ? _a : 'http://offline';
                const pid = (_b = state.pid) !== null && _b !== void 0 ? _b : -1;
                return { type: 'localDatabase', pid, name, id: name, url, running };
            });
        });
    }
    createLocalDatabase(args) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            // TODO: once ppg dev has a daemon, this should be replaced
            const { name } = args;
            const [port, databasePort, shadowDatabasePort] = (yield (0, getUniquePorts_1.getUniquePorts)(3)).map(String);
            const { path: ppgDevServerPath } = vscode_1.Uri.joinPath(this.context.extensionUri, ...['dist', 'src', 'plugins', 'prisma-postgres-manager', 'utils', 'spawnPpgDevServer.js']);
            const child = (0, child_process_1.fork)(ppgDevServerPath, [name, port, databasePort, shadowDatabasePort], {
                stdio: ['ignore', 'pipe', 'pipe', 'ipc'],
                detached: true,
            });
            child.on('error', (error) => console.error(`[PPG Dev] Process (${name}) error for database:`, error));
            child.on('exit', (code, signal) => console.log(`[PPG Dev] Process (${name}) exited (${code}, ${signal})`));
            child.on('spawn', () => console.log(`[PPG Dev] Process (${name}) spawned successfully`));
            (_a = child.stdout) === null || _a === void 0 ? void 0 : _a.on('data', (data) => console.log(`[PPG Child ${name}] ${String(data).trim()}`));
            (_b = child.stderr) === null || _b === void 0 ? void 0 : _b.on('data', (data) => console.error(`[PPG Child ${name}] ${String(data).trim()}`));
            (0, proxy_signals_1.proxySignals)(child); // closes the children if parent is closed (ie. vscode)
            yield (0, waitForPortBorrowed_1.waitForPortBorrowed)(+port);
            void this.refreshLocalDatabases();
        });
    }
    startLocalDatabase(args) {
        return __awaiter(this, void 0, void 0, function* () {
            const { pid, name } = args;
            if ((0, isPidRunning_1.isPidRunning)(pid) === false || pid === process.pid) {
                console.log(`[startLocalDatabase] starting local database ${name}`);
                yield this.createLocalDatabase(args);
            }
            else {
                console.log(`[startLocalDatabase] local database ${name} already started`);
            }
        });
    }
    deleteLocalDatabase(args) {
        return __awaiter(this, void 0, void 0, function* () {
            const { pid, name, url } = args;
            const databasePath = path.join(PPG_DEV_GLOBAL_ROOT.data, name);
            try {
                yield this.stopLocalDatabase({ pid, url }).catch(() => { });
                yield fs.rm(databasePath, { recursive: true, force: true });
                console.log(`[deleteLocalDatabase] Deleted local database folder: ${databasePath}`);
            }
            catch (error) {
                console.error(`[deleteLocalDatabase] Failed to delete local database folder: ${databasePath}`, error);
            }
            void this.refreshLocalDatabases();
        });
    }
    stopLocalDatabase(args) {
        return __awaiter(this, void 0, void 0, function* () {
            const { pid, url } = args;
            const { port } = new URL(url);
            process.kill(pid, 'SIGTERM');
            yield (0, waitForPortAvailable_1.waitForPortAvailable)(+port);
            void this.refreshLocalDatabases();
        });
    }
    deployLocalDatabase(args) {
        return __awaiter(this, void 0, void 0, function* () {
            const { Client } = yield import('@prisma/ppg');
            const { ServerState } = yield import('@prisma/dev/internal/state');
            const { dumpDB } = yield import('@prisma/dev/internal/db');
            const { name, url, projectId, workspaceId } = args;
            const state = yield ServerState.createExclusively({ name, persistenceMode: 'stateful' });
            try {
                const dump = yield dumpDB({ dataDir: state.pgliteDataDirPath });
                yield new Client({ connectionString: url }).query(dump, []);
            }
            catch (e) {
                yield state.close();
                throw e;
            }
            yield state.close();
            void this.refreshProjects({ workspaceId });
            void this.refreshRemoteDatabases({ projectId, workspaceId });
        });
    }
}
exports.PrismaPostgresRepository = PrismaPostgresRepository;
//# sourceMappingURL=PrismaPostgresRepository.js.map