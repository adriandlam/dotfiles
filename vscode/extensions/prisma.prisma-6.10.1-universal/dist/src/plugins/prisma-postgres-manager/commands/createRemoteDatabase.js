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
exports.createRemoteDatabaseSafely = exports.createRemoteDatabase = exports.CreateRemoteDatabaseArgsSchema = void 0;
const vscode_1 = require("vscode");
const PrismaPostgresRepository_1 = require("../PrismaPostgresRepository");
const createProjectInclDatabase_1 = require("./createProjectInclDatabase");
const handleCommandError_1 = require("../shared-ui/handleCommandError");
const connectionStringMessage_1 = require("../shared-ui/connectionStringMessage");
const pickRegion_1 = require("../shared-ui/pickRegion");
const zod_1 = __importDefault(require("zod"));
exports.CreateRemoteDatabaseArgsSchema = zod_1.default.union([PrismaPostgresRepository_1.ProjectSchema, zod_1.default.undefined()]);
const pickProject = (ppgRepository, options) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    const workspaces = yield ppgRepository.getWorkspaces();
    if (workspaces.length === 0) {
        throw new handleCommandError_1.CommandAbortError('You need to login to Prisma before you can create a remote database.'); // TODO: trigger login flow
    }
    const workspacesWithProjects = yield Promise.all(workspaces.map((workspace) => __awaiter(void 0, void 0, void 0, function* () {
        return (Object.assign(Object.assign({}, workspace), { projects: yield ppgRepository.getProjects({ workspaceId: workspace.id }) }));
    })));
    if (workspacesWithProjects.every((workspace) => workspace.projects.length === 0)) {
        const result = yield (0, createProjectInclDatabase_1.createProjectInclDatabaseSafely)(ppgRepository, workspaces[0], options);
        return {
            workspaceId: workspaces[0].id,
            projectId: result.project.id,
            databaseId: (_a = result.database) === null || _a === void 0 ? void 0 : _a.id,
        };
    }
    const projectsQuickPickItems = workspacesWithProjects.flatMap((workspace) => {
        return [
            { type: 'workspace', label: workspace.name, kind: vscode_1.QuickPickItemKind.Separator },
            ...workspace.projects.map((p) => ({
                type: 'project',
                id: p.id,
                workspaceId: workspace.id,
                label: p.name,
                iconPath: new vscode_1.ThemeIcon('project'),
            })),
            {
                type: 'create-project',
                label: 'Create Project',
                iconPath: new vscode_1.ThemeIcon('plus'),
                workspaceId: workspace.id,
            },
        ];
    });
    const selectedItem = yield vscode_1.window.showQuickPick(projectsQuickPickItems, {
        placeHolder: 'Choose a project',
    });
    if ((selectedItem === null || selectedItem === void 0 ? void 0 : selectedItem.type) === 'create-project') {
        return { workspaceId: selectedItem.workspaceId };
    }
    else if ((selectedItem === null || selectedItem === void 0 ? void 0 : selectedItem.type) === 'project') {
        return { workspaceId: selectedItem.workspaceId, projectId: selectedItem.id };
    }
    else {
        throw new handleCommandError_1.CommandAbortError('No project selected');
    }
});
const createRemoteDatabase = (ppgRepository, args, options) => __awaiter(void 0, void 0, void 0, function* () {
    const validatedArgs = exports.CreateRemoteDatabaseArgsSchema.parse(args);
    let workspaceId = validatedArgs === null || validatedArgs === void 0 ? void 0 : validatedArgs.workspaceId;
    let projectId = validatedArgs === null || validatedArgs === void 0 ? void 0 : validatedArgs.id;
    let databaseId;
    if (workspaceId === undefined || projectId === undefined) {
        ;
        ({ workspaceId, projectId, databaseId } = yield pickProject(ppgRepository, options));
    }
    const workspaces = yield ppgRepository.getWorkspaces();
    const workspace = workspaces.find((w) => (w.id = workspaceId));
    if (databaseId)
        return; // pickProject already created a new project incl database
    if (!projectId)
        return (0, createProjectInclDatabase_1.createProjectInclDatabaseSafely)(ppgRepository, workspace, options);
    const regions = ppgRepository.getRegions();
    const name = yield vscode_1.window.showInputBox({
        prompt: 'Enter the name of the remote database',
    });
    if (!name)
        throw new handleCommandError_1.CommandAbortError('Name is required');
    const region = yield (0, pickRegion_1.pickRegion)(yield regions);
    const database = yield vscode_1.window.withProgress({
        location: vscode_1.ProgressLocation.Notification,
        title: `Creating remote database...`,
    }, () => ppgRepository.createRemoteDatabase({
        workspaceId,
        projectId,
        name,
        region: region.id,
        options,
    }));
    yield (0, connectionStringMessage_1.presentConnectionString)({
        connectionString: database.connectionString,
        type: 'databaseCreated',
    });
    return { project: { workspaceId, id: projectId }, database };
});
exports.createRemoteDatabase = createRemoteDatabase;
const createRemoteDatabaseSafely = (ppgRepository, args, options) => __awaiter(void 0, void 0, void 0, function* () {
    return (0, exports.createRemoteDatabase)(ppgRepository, args, options);
});
exports.createRemoteDatabaseSafely = createRemoteDatabaseSafely;
//# sourceMappingURL=createRemoteDatabase.js.map