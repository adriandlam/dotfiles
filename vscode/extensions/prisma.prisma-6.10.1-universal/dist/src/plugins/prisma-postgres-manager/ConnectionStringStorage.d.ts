import type { SecretStorage } from 'vscode';
export declare class ConnectionStringStorage {
    private readonly vscodeSecretStorage;
    constructor(vscodeSecretStorage: SecretStorage);
    storeConnectionString({ workspaceId, projectId, databaseId, connectionString, }: {
        workspaceId: string;
        projectId: string;
        databaseId: string;
        connectionString: string;
    }): Promise<void>;
    getConnectionString({ workspaceId, projectId, databaseId, }: {
        workspaceId: string;
        projectId: string;
        databaseId: string;
    }): Promise<string | undefined>;
    removeConnectionString({ workspaceId, projectId, databaseId, }: {
        workspaceId: string;
        projectId?: string;
        databaseId?: string;
    }): Promise<void>;
    private storeConnectionStrings;
    private getStoredConnectionStrings;
}
