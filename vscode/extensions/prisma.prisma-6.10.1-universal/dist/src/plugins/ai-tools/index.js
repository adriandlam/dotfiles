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
const execa_1 = require("execa");
function runCommand(_a) {
    return __awaiter(this, arguments, void 0, function* ({ args, cwd, cancelToken }) {
        const childProcess = (0, execa_1.command)('npx -y prisma ' + args.join(' '), { cwd });
        cancelToken.onCancellationRequested(() => {
            childProcess.cancel();
        });
        const result = yield childProcess;
        return `${result.stdout}\n${result.stderr}`;
    });
}
class MigrateStatusTool {
    invoke(options, cancelToken) {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield runCommand({
                args: ['migrate', 'status'],
                cwd: options.input.projectCwd,
                cancelToken,
            });
            return new vscode_1.LanguageModelToolResult([new vscode_1.LanguageModelTextPart(result)]);
        });
    }
    prepareInvocation(_options, _token) {
        return {
            invocationMessage: 'Getting Prisma migrate status...',
        };
    }
}
class MigrateDevTool {
    invoke(options, cancelToken) {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield runCommand({
                args: ['migrate', 'dev', '--name', options.input.name],
                cwd: options.input.projectCwd,
                cancelToken,
            });
            return new vscode_1.LanguageModelToolResult([new vscode_1.LanguageModelTextPart(result)]);
        });
    }
    prepareInvocation(options, _token) {
        return {
            invocationMessage: `Running \`prisma migrate dev\` with name ${options.input.name}...`,
        };
    }
}
class MigrateResetTool {
    invoke(options, cancelToken) {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield runCommand({
                args: ['migrate', 'reset', '--force'],
                cwd: options.input.projectCwd,
                cancelToken,
            });
            return new vscode_1.LanguageModelToolResult([new vscode_1.LanguageModelTextPart(result)]);
        });
    }
    prepareInvocation(_options, _token) {
        return {
            invocationMessage: 'Resetting database...',
        };
    }
}
class StudioTool {
    invoke(options, cancelToken) {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield runCommand({
                args: ['studio'],
                cwd: options.input.projectCwd,
                cancelToken,
            });
            return new vscode_1.LanguageModelToolResult([new vscode_1.LanguageModelTextPart(result)]);
        });
    }
    prepareInvocation(_options, _token) {
        return {
            invocationMessage: 'Running Prisma Studio...',
        };
    }
}
const plugin = {
    name: 'prisma-local-ai-tools',
    enabled: () => true,
    activate: (context) => {
        context.subscriptions.push(vscode_1.lm.registerTool('prisma-migrate-status', new MigrateStatusTool()));
        context.subscriptions.push(vscode_1.lm.registerTool('prisma-migrate-dev', new MigrateDevTool()));
        context.subscriptions.push(vscode_1.lm.registerTool('prisma-migrate-reset', new MigrateResetTool()));
        context.subscriptions.push(vscode_1.lm.registerTool('prisma-studio', new StudioTool()));
    },
    deactivate: () => { },
};
exports.default = plugin;
//# sourceMappingURL=index.js.map