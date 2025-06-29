"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PDPAuthLoginTool = void 0;
const vscode_1 = require("vscode");
class PDPAuthLoginTool {
    invoke() {
        void vscode_1.commands.executeCommand('prisma.login');
        return new vscode_1.LanguageModelToolResult([
            new vscode_1.LanguageModelTextPart('Login kicked off. Please let the user follow the instructions of VSCode and their Browser to complete the login.'),
        ]);
    }
    prepareInvocation(_options, _token) {
        return {
            invocationMessage: 'Starting Prisma Workspace login...',
        };
    }
}
exports.PDPAuthLoginTool = PDPAuthLoginTool;
//# sourceMappingURL=PDPAuthLoginTool.js.map