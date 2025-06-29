import { ExtensionContext } from 'vscode';
/**
 * Opens Prisma Studio in a webview panel.
 * @param args - An object containing the database URL and extension context.
 */
export declare function openNewStudioTab(args: {
    dbUrl: string;
    context: ExtensionContext;
}): Promise<void>;
