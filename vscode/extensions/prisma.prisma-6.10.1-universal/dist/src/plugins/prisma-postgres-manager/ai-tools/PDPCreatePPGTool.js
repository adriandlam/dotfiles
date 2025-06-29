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
exports.PDPCreatePPGTool = void 0;
const vscode_1 = require("vscode");
class PDPCreatePPGTool {
    constructor(ppgRepository) {
        this.ppgRepository = ppgRepository;
    }
    invoke(options, _cancelToken) {
        return __awaiter(this, void 0, void 0, function* () {
            const workspaces = yield this.ppgRepository.getWorkspaces();
            if (workspaces.length === 0) {
                return new vscode_1.LanguageModelToolResult([
                    new vscode_1.LanguageModelTextPart('User is not authenticated to any workspaces. Ask them to login. You can use the prisma-platform-login tool for this.'),
                ]);
            }
            if (workspaces.length > 1 && !options.input.workspaceId) {
                return new vscode_1.LanguageModelToolResult([
                    new vscode_1.LanguageModelTextPart(`User is authenticated to multiple workspaces. Please specify the workspaceId to create the database in. Let the user choose one of the following workspaces and call this tool again with the corresponding workspaceId.`),
                    new vscode_1.LanguageModelTextPart(`Available workspaces: ${JSON.stringify(workspaces)}`),
                ]);
            }
            let workspace;
            if (options.input.workspaceId) {
                workspace = workspaces.find((w) => w.id === options.input.workspaceId);
            }
            if (workspaces.length === 1) {
                workspace = workspaces[0];
            }
            if (!workspace) {
                return new vscode_1.LanguageModelToolResult([new vscode_1.LanguageModelTextPart('Workspace not found. Please try again.')]);
            }
            const regions = yield this.ppgRepository.getRegions();
            if (!options.input.regionId) {
                return new vscode_1.LanguageModelToolResult([
                    new vscode_1.LanguageModelTextPart('Region not specified. Please try again.'),
                    new vscode_1.LanguageModelTextPart(`Available regions: ${JSON.stringify(regions)}`),
                ]);
            }
            const toolResults = [];
            try {
                const result = yield this.ppgRepository.createProject({
                    workspaceId: workspace.id,
                    name: options.input.name,
                    region: options.input.regionId,
                    options: {},
                });
                toolResults.push(new vscode_1.LanguageModelTextPart(`Project ${result.project.name} created successfully.`), new vscode_1.LanguageModelTextPart(`Project info: ${JSON.stringify(result.project)}`));
                if (result.database) {
                    toolResults.push(new vscode_1.LanguageModelTextPart(`You can now connect to the database via the connection string: ${result.database.connectionString}`), new vscode_1.LanguageModelTextPart(`Database info: ${JSON.stringify(result.database)}`));
                }
            }
            catch (error) {
                const errorMessage = error instanceof Error ? error.message : JSON.stringify(error);
                toolResults.push(new vscode_1.LanguageModelTextPart('Error creating project. Please try again.'), new vscode_1.LanguageModelTextPart('Error Details: ' + errorMessage));
            }
            return new vscode_1.LanguageModelToolResult(toolResults);
        });
    }
    prepareInvocation(options, _token) {
        return {
            invocationMessage: `Creating Prisma Postgres database ${options.input.name}...`,
        };
    }
}
exports.PDPCreatePPGTool = PDPCreatePPGTool;
//# sourceMappingURL=PDPCreatePPGTool.js.map