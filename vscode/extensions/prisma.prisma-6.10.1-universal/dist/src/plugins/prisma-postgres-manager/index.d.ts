import { ExtensionContext } from 'vscode';
declare const _default: {
    name: string;
    enabled(): boolean;
    activate(context: ExtensionContext): void;
    deactivate(): void;
};
export default _default;
