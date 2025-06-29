"use strict";
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
exports.ConnectionStringStorage = void 0;
const zod_1 = __importDefault(require("zod"));
const WorkspaceIdSchema = zod_1.default.string();
const ProjectIdSchema = zod_1.default.string();
const DatabaseIdSchema = zod_1.default.string();
// Storing connection strings in this JSON structure under a single key in the secret storage.
// This allows for easy deletion of multiple entries when a project is deleted or the user logs out from a workspace.
const StoredConnectionStringsSchema = zod_1.default.object({
    workspaces: zod_1.default.record(WorkspaceIdSchema, zod_1.default.object({
        projects: zod_1.default.record(ProjectIdSchema, zod_1.default.object({
            databases: zod_1.default.record(DatabaseIdSchema, zod_1.default.object({
                connectionString: zod_1.default.string(),
            })),
        })),
    })),
});
const STORED_CREDENTIALS_KEY = 'prisma-postgres.connection-strings';
class ConnectionStringStorage {
    constructor(vscodeSecretStorage) {
        this.vscodeSecretStorage = vscodeSecretStorage;
    }
    storeConnectionString(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId, databaseId, connectionString, }) {
            var _b, _c, _d, _e;
            const storage = yield this.getStoredConnectionStrings();
            const updatedStorage = Object.assign(Object.assign({}, storage), { workspaces: Object.assign(Object.assign({}, storage.workspaces), { [workspaceId]: Object.assign(Object.assign({}, storage.workspaces[workspaceId]), { projects: Object.assign(Object.assign({}, (_b = storage.workspaces[workspaceId]) === null || _b === void 0 ? void 0 : _b.projects), { [projectId]: Object.assign(Object.assign({}, (_c = storage.workspaces[workspaceId]) === null || _c === void 0 ? void 0 : _c.projects[projectId]), { databases: Object.assign(Object.assign({}, (_e = (_d = storage.workspaces[workspaceId]) === null || _d === void 0 ? void 0 : _d.projects[projectId]) === null || _e === void 0 ? void 0 : _e.databases), { [databaseId]: {
                                        connectionString,
                                    } }) }) }) }) }) });
            yield this.storeConnectionStrings(updatedStorage);
        });
    }
    getConnectionString(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId, databaseId, }) {
            var _b, _c, _d;
            const storage = yield this.getStoredConnectionStrings();
            return (_d = (_c = (_b = storage.workspaces[workspaceId]) === null || _b === void 0 ? void 0 : _b.projects[projectId]) === null || _c === void 0 ? void 0 : _c.databases[databaseId]) === null || _d === void 0 ? void 0 : _d.connectionString;
        });
    }
    removeConnectionString(_a) {
        return __awaiter(this, arguments, void 0, function* ({ workspaceId, projectId, databaseId, }) {
            const storage = yield this.getStoredConnectionStrings();
            if (databaseId && projectId) {
                delete storage.workspaces[workspaceId].projects[projectId].databases[databaseId];
            }
            else if (databaseId && !projectId) {
                throw new Error('When databaseId is provided, projectId is required');
            }
            else if (projectId) {
                delete storage.workspaces[workspaceId].projects[projectId];
            }
            else {
                delete storage.workspaces[workspaceId];
            }
            yield this.storeConnectionStrings(storage);
        });
    }
    storeConnectionStrings(connectionStrings) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.vscodeSecretStorage.store(STORED_CREDENTIALS_KEY, JSON.stringify(connectionStrings));
        });
    }
    getStoredConnectionStrings() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const storedCredentials = yield this.vscodeSecretStorage.get(STORED_CREDENTIALS_KEY);
                return StoredConnectionStringsSchema.parse(JSON.parse(storedCredentials || '{ "workspaces": {} }'));
            }
            catch (error) {
                console.error('Error getting stored connection strings', error);
                return { workspaces: {} };
            }
        });
    }
}
exports.ConnectionStringStorage = ConnectionStringStorage;
//# sourceMappingURL=ConnectionStringStorage.js.map