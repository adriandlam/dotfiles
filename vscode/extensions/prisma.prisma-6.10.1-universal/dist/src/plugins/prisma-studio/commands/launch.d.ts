import { ExtensionContext } from 'vscode';
/**
 * Launches Prisma Studio, prompting for a database URL if not provided.
 * @param args - An object containing the database URL and extension context.
 */
export declare function launch(args: {
    dbUrl?: string;
    context: ExtensionContext;
}): Promise<string | void>;
