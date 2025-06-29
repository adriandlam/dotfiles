import * as vscode from 'vscode';
/**
 * CodelensProvider
 */
export declare class CodelensProvider implements vscode.CodeLensProvider {
    private enabled;
    private generatorRegex;
    private _onDidChangeCodeLenses;
    readonly onDidChangeCodeLenses: vscode.Event<void>;
    constructor();
    provideCodeLenses(document: vscode.TextDocument, token: vscode.CancellationToken): vscode.CodeLens[];
    private getCodeLensGenerateSchema;
    private getGeneratorRange;
}
export declare function generateClient(_args: string): void;
