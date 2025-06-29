import { ExtensionContext } from 'vscode';
/**
 * Starts a local server for Prisma Studio and serves the UI files.
 * @param args - An object containing the static files root URI.
 * @returns The URL of the running server.
 */
export declare function startStudioServer(args: {
    dbUrl: string;
    context: ExtensionContext;
}): Promise<{
    server: import("@hono/node-server").ServerType;
    url: string;
}>;
