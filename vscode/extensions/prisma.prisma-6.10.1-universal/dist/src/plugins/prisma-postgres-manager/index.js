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
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const PrismaPostgresTreeDataProvider_1 = require("./PrismaPostgresTreeDataProvider");
const createRemoteDatabase_1 = require("./commands/createRemoteDatabase");
const PrismaPostgresRepository_1 = require("./PrismaPostgresRepository");
const createProjectInclDatabase_1 = require("./commands/createProjectInclDatabase");
const deleteProject_1 = require("./commands/deleteProject");
const deleteRemoteDatabase_1 = require("./commands/deleteRemoteDatabase");
const handleCommandError_1 = require("./shared-ui/handleCommandError");
const logout_1 = require("./commands/logout");
const login_1 = require("./commands/login");
const auth_1 = require("./management-api/auth");
const ConnectionStringStorage_1 = require("./ConnectionStringStorage");
const getRemoteDatabaseConnectionString_1 = require("./commands/getRemoteDatabaseConnectionString");
const launchStudio_1 = require("./commands/launchStudio");
const PDPAuthLoginTool_1 = require("./ai-tools/PDPAuthLoginTool");
const PDPCreatePPGTool_1 = require("./ai-tools/PDPCreatePPGTool");
const createLocalDatabase_1 = require("./commands/createLocalDatabase");
const stopLocalDatabase_1 = require("./commands/stopLocalDatabase");
const startLocalDatabase_1 = require("./commands/startLocalDatabase");
const copyLocalDatabaseUrl_1 = require("./commands/copyLocalDatabaseUrl");
const deleteLocalDatabase_1 = require("./commands/deleteLocalDatabase");
const deployLocalDatabase_1 = require("./commands/deployLocalDatabase");
exports.default = {
    name: 'Prisma Postgres',
    enabled() {
        return true;
    },
    activate(context) {
        const auth = new auth_1.Auth(context.extension.id);
        const connectionStringStorage = new ConnectionStringStorage_1.ConnectionStringStorage(context.secrets);
        const ppgRepository = new PrismaPostgresRepository_1.PrismaPostgresRepository(auth, connectionStringStorage, context);
        const ppgProvider = new PrismaPostgresTreeDataProvider_1.PrismaPostgresTreeDataProvider(ppgRepository);
        vscode_1.window.registerUriHandler({
            handleUri(uri) {
                void (0, login_1.handleAuthCallback)({ uri, ppgRepository, auth });
            },
        });
        vscode_1.window.registerTreeDataProvider('prismaPostgresDatabases', ppgProvider);
        context.subscriptions.push(vscode_1.commands.registerCommand('prisma.refresh', () => {
            ppgRepository.triggerRefresh();
        }), vscode_1.commands.registerCommand('prisma.login', () => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Login', () => (0, login_1.login)(ppgRepository, auth));
        })), vscode_1.commands.registerCommand('prisma.logout', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Logout', () => (0, logout_1.logout)(ppgRepository, args));
        })), vscode_1.commands.registerCommand('prisma.createProject', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Create Project', () => (0, createProjectInclDatabase_1.createProjectInclDatabase)(ppgRepository, args, {}));
        })), vscode_1.commands.registerCommand('prisma.deleteProject', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Delete Project', () => (0, deleteProject_1.deleteProject)(ppgRepository, args));
        })), vscode_1.commands.registerCommand('prisma.openProjectInPrismaConsole', (args) => __awaiter(this, void 0, void 0, function* () {
            if ((0, PrismaPostgresRepository_1.isProject)(args)) {
                yield vscode_1.env.openExternal(vscode_1.Uri.parse(`https://console.prisma.io/${args.workspaceId}/${args.id}/environments`));
            }
            else {
                throw new Error('Invalid arguments');
            }
        })), vscode_1.commands.registerCommand('prisma.createRemoteDatabase', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Create Remote Database', () => (0, createRemoteDatabase_1.createRemoteDatabase)(ppgRepository, args, {}));
        })), vscode_1.commands.registerCommand('prisma.getRemoteDatabaseConnectionString', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Get Connection String', () => (0, getRemoteDatabaseConnectionString_1.getRemoteDatabaseConnectionString)(ppgRepository, args));
        })), vscode_1.commands.registerCommand('prisma.openRemoteDatabaseInPrismaConsole', (args) => __awaiter(this, void 0, void 0, function* () {
            if ((0, PrismaPostgresRepository_1.isRemoteDatabase)(args)) {
                yield vscode_1.env.openExternal(vscode_1.Uri.parse(`https://console.prisma.io/${args.workspaceId}/${args.projectId}/${args.id}/dashboard`));
            }
            else {
                throw new Error('Invalid arguments');
            }
        })), vscode_1.commands.registerCommand('prisma.deleteRemoteDatabase', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Delete Remote Database', () => (0, deleteRemoteDatabase_1.deleteRemoteDatabase)(ppgRepository, args));
        })), vscode_1.commands.registerCommand('prisma.studio.launchForDatabase', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Launch Studio', () => (0, launchStudio_1.launchStudio)({ ppgRepository, args, context }));
        })), 
        /** Local Db Commands */
        vscode_1.commands.registerCommand('prisma.createLocalDatabase', () => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Create Local Database', () => (0, createLocalDatabase_1.createLocalDatabase)(ppgRepository));
        })), vscode_1.commands.registerCommand('prisma.stopLocalDatabase', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Stop Local Database', () => (0, stopLocalDatabase_1.stopLocalDatabase)(ppgRepository, args));
        })), vscode_1.commands.registerCommand('prisma.startLocalDatabase', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Start Local Database', () => (0, startLocalDatabase_1.startLocalDatabase)(ppgRepository, args));
        })), vscode_1.commands.registerCommand('prisma.deleteLocalDatabase', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Delete Local Database', () => (0, deleteLocalDatabase_1.deleteLocalDatabase)(ppgRepository, args));
        })), vscode_1.commands.registerCommand('prisma.copyLocalDatabaseURL', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Copy Local Database URL', () => (0, copyLocalDatabaseUrl_1.copyLocalDatabaseUrl)(args));
        })), vscode_1.commands.registerCommand('prisma.deployLocalDatabase', (args) => __awaiter(this, void 0, void 0, function* () {
            yield (0, handleCommandError_1.handleCommandError)('Deploy Local Database', () => (0, deployLocalDatabase_1.deployLocalDatabase)(ppgRepository, args));
        })));
        context.subscriptions.push(vscode_1.lm.registerTool('prisma-platform-login', new PDPAuthLoginTool_1.PDPAuthLoginTool()));
        context.subscriptions.push(vscode_1.lm.registerTool('prisma-postgres-create-database', new PDPCreatePPGTool_1.PDPCreatePPGTool(ppgRepository)));
    },
    deactivate() { },
};
//# sourceMappingURL=index.js.map