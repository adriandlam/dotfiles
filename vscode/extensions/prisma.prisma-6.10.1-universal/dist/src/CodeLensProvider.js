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
Object.defineProperty(exports, "__esModule", { value: true });
exports.CodelensProvider = void 0;
exports.generateClient = generateClient;
const vscode = __importStar(require("vscode"));
const cp = __importStar(require("child_process"));
/**
 * CodelensProvider
 */
class CodelensProvider {
    constructor() {
        this._onDidChangeCodeLenses = new vscode.EventEmitter();
        this.onDidChangeCodeLenses = this._onDidChangeCodeLenses.event;
        this.generatorRegex = /(generator +[a-zA-Z0-9]+ +{)/g;
        this.enabled = vscode.workspace.getConfiguration('prisma').get('enableCodeLens', true);
        vscode.workspace.onDidChangeConfiguration((_) => {
            this._onDidChangeCodeLenses.fire();
        });
    }
    provideCodeLenses(document, token) {
        if (!this.enabled) {
            return [];
        }
        const codelenses = this.getCodeLensGenerateSchema(document, token);
        return [].concat(...codelenses);
    }
    getCodeLensGenerateSchema(document, token) {
        const generatorRanges = this.getGeneratorRange(document, token);
        const lenses = generatorRanges.map((range) => new vscode.CodeLens(range, {
            title: 'Generate',
            command: 'prisma.generate',
            tooltip: `Run "prisma generate"`,
            // ? (@druue) The arguments property does not seem to actually
            // ? return an array of arguments. It would consistently
            // ? return one singular string element, even when defined as:
            // ? [this.scriptRunner, this.schemaPath]
            // ?
            // ? I've tried to understand why as there are usages in other
            // ? codebases that do pass in multiple args so I have to imagine
            // ? that it can work, but unsure.
            // ? Reference: https://github.com/microsoft/vscode-extension-samples/blob/main/codelens-sample/
            // ? arguments: [this.scriptRunner]
        }));
        return lenses;
    }
    // ? (@druue) I really don't like finding it like this :|
    getGeneratorRange(document, _token) {
        const regex = new RegExp(this.generatorRegex);
        const text = document.getText();
        const ranges = [];
        let matches;
        while ((matches = regex.exec(text)) !== null) {
            const line = document.lineAt(document.positionAt(matches.index).line);
            const indexOf = line.text.indexOf(matches[0]);
            const position = new vscode.Position(line.lineNumber, indexOf);
            const range = document.getWordRangeAtPosition(position, new RegExp(this.generatorRegex));
            if (range) {
                ranges.push(range);
            }
        }
        return ranges;
    }
}
exports.CodelensProvider = CodelensProvider;
function generateClient(_args) {
    var _a;
    const prismaGenerateOutputChannel = vscode.window.createOutputChannel('Prisma Generate');
    const rootPath = (_a = vscode.workspace.workspaceFolders) === null || _a === void 0 ? void 0 : _a[0].uri.fsPath;
    const scriptRunner = vscode.workspace.getConfiguration('prisma').get('scriptRunner', 'npx');
    const schemaPath = vscode.workspace.getConfiguration('prisma').get('schemaPath');
    const pathArgFlag = ` --schema=${schemaPath}`;
    const cmd = `${scriptRunner} prisma generate${schemaPath ? pathArgFlag : ''}`;
    prismaGenerateOutputChannel.clear();
    prismaGenerateOutputChannel.show(true);
    prismaGenerateOutputChannel.appendLine(['Running prisma generate:', rootPath, cmd].join('\n- '));
    const handleExec = (err, stdout, stderr) => {
        try {
            if (err) {
                prismaGenerateOutputChannel.appendLine(err.message);
                return;
            }
            if (stdout) {
                prismaGenerateOutputChannel.append(stdout);
            }
            if (stderr) {
                prismaGenerateOutputChannel.append(stderr);
            }
        }
        catch (e) {
            prismaGenerateOutputChannel.append(e);
        }
    };
    cp.exec(cmd, { cwd: rootPath }, (err, stdout, stderr) => handleExec(err, stdout, stderr));
}
//# sourceMappingURL=CodeLensProvider.js.map