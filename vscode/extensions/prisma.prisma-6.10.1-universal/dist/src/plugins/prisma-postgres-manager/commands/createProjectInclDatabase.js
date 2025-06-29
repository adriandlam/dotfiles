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
exports.createProjectInclDatabaseSafely = exports.createProjectInclDatabase = exports.CreateProjectInclDatabaseArgsSchema = void 0;
const vscode_1 = require("vscode");
const PrismaPostgresRepository_1 = require("../PrismaPostgresRepository");
const pickWorkspace_1 = require("../shared-ui/pickWorkspace");
const handleCommandError_1 = require("../shared-ui/handleCommandError");
const connectionStringMessage_1 = require("../shared-ui/connectionStringMessage");
const pickRegion_1 = require("../shared-ui/pickRegion");
const zod_1 = __importDefault(require("zod"));
exports.CreateProjectInclDatabaseArgsSchema = zod_1.default.union([PrismaPostgresRepository_1.WorkspaceSchema, zod_1.default.undefined()]);
const createProjectInclDatabase = (ppgRepository, args, options) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    const validatedArgs = exports.CreateProjectInclDatabaseArgsSchema.parse(args);
    let workspaceId = validatedArgs === null || validatedArgs === void 0 ? void 0 : validatedArgs.id;
    if (workspaceId === undefined) {
        workspaceId = (yield (0, pickWorkspace_1.pickWorkspace)(ppgRepository)).id;
    }
    const regions = ppgRepository.getRegions();
    const name = yield vscode_1.window.showInputBox({
        prompt: 'Enter the name of the new project',
    });
    if (!name)
        throw new handleCommandError_1.CommandAbortError('Project name is required');
    const region = yield (0, pickRegion_1.pickRegion)(yield regions);
    const result = yield vscode_1.window.withProgress({
        location: vscode_1.ProgressLocation.Notification,
        title: `Creating project with database...`,
    }, () => ppgRepository.createProject({ workspaceId, name, region: region.id, options }));
    if ((_a = result.database) === null || _a === void 0 ? void 0 : _a.connectionString) {
        yield (0, connectionStringMessage_1.presentConnectionString)({
            connectionString: result.database.connectionString,
            type: 'databaseCreated',
        });
    }
    else {
        void vscode_1.window.showInformationMessage(`Project created`);
    }
    return result;
});
exports.createProjectInclDatabase = createProjectInclDatabase;
const createProjectInclDatabaseSafely = (ppgRepository, args, options) => __awaiter(void 0, void 0, void 0, function* () {
    return (0, exports.createProjectInclDatabase)(ppgRepository, args, options);
});
exports.createProjectInclDatabaseSafely = createProjectInclDatabaseSafely;
//# sourceMappingURL=createProjectInclDatabase.js.map