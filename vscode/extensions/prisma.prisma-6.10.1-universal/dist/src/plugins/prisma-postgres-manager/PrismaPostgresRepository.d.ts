import { EventEmitter, ExtensionContext } from 'vscode';
import type { ConnectionStringStorage } from './ConnectionStringStorage';
import { Auth } from './management-api/auth';
import type { paths } from './management-api/api.d';
import { z } from 'zod';
export type RegionId = NonNullable<NonNullable<paths['/projects/{projectId}/databases']['post']['requestBody']>['content']['application/json']['region']>;
export type Region = {
    id: string;
    name: string;
    status: 'available' | 'unavailable' | 'unsupported';
};
export declare const WorkspaceSchema: z.ZodObject<{
    type: z.ZodLiteral<"workspace">;
    id: z.ZodString;
    name: z.ZodString;
}, "strip", z.ZodTypeAny, {
    type: "workspace";
    id: string;
    name: string;
}, {
    type: "workspace";
    id: string;
    name: string;
}>;
export type WorkspaceId = string;
export type Workspace = z.infer<typeof WorkspaceSchema>;
export declare function isWorkspace(item: unknown): item is Workspace;
export declare const ProjectSchema: z.ZodObject<{
    type: z.ZodLiteral<"project">;
    id: z.ZodString;
    name: z.ZodString;
    workspaceId: z.ZodString;
}, "strip", z.ZodTypeAny, {
    type: "project";
    workspaceId: string;
    id: string;
    name: string;
}, {
    type: "project";
    workspaceId: string;
    id: string;
    name: string;
}>;
export type ProjectId = string;
export type Project = z.infer<typeof ProjectSchema>;
export declare function isProject(item: unknown): item is Project;
export declare const RemoteDatabaseSchema: z.ZodObject<{
    type: z.ZodLiteral<"remoteDatabase">;
    id: z.ZodString;
    name: z.ZodString;
    region: z.ZodNullable<z.ZodString>;
    projectId: z.ZodString;
    workspaceId: z.ZodString;
}, "strip", z.ZodTypeAny, {
    type: "remoteDatabase";
    workspaceId: string;
    projectId: string;
    region: string | null;
    id: string;
    name: string;
}, {
    type: "remoteDatabase";
    workspaceId: string;
    projectId: string;
    region: string | null;
    id: string;
    name: string;
}>;
export type RemoteDatabaseId = string;
export type RemoteDatabase = z.infer<typeof RemoteDatabaseSchema>;
export declare function isRemoteDatabase(item: unknown): item is RemoteDatabase;
export declare const LocalDatabaseSchema: z.ZodObject<{
    type: z.ZodLiteral<"localDatabase">;
    id: z.ZodString;
    name: z.ZodString;
    url: z.ZodString;
    pid: z.ZodNumber;
    running: z.ZodBoolean;
}, "strip", z.ZodTypeAny, {
    type: "localDatabase";
    id: string;
    name: string;
    url: string;
    pid: number;
    running: boolean;
}, {
    type: "localDatabase";
    id: string;
    name: string;
    url: string;
    pid: number;
    running: boolean;
}>;
export type LocalDatabase = z.infer<typeof LocalDatabaseSchema>;
export declare function isLocalDatabase(item: unknown): item is LocalDatabase;
export type NewRemoteDatabase = RemoteDatabase & {
    connectionString: string;
};
export type PrismaPostgresItem = {
    type: 'localRoot';
} | {
    type: 'remoteRoot';
} | Workspace | Project | RemoteDatabase | LocalDatabase;
export declare class PrismaPostgresRepository {
    private readonly auth;
    private readonly connectionStringStorage;
    private readonly context;
    private clients;
    private credentialsStore;
    private regionsCache;
    private workspacesCache;
    private projectsCache;
    private remoteDatabasesCache;
    readonly refreshEventEmitter: EventEmitter<void | PrismaPostgresItem>;
    constructor(auth: Auth, connectionStringStorage: ConnectionStringStorage, context: ExtensionContext);
    private getClient;
    private checkResponseOrThrow;
    triggerRefresh(): void;
    getRegions(): Promise<Region[]>;
    private ensureValidRegion;
    getWorkspaces(): Promise<Workspace[]>;
    addWorkspace({ token, refreshToken }: {
        token: string;
        refreshToken: string;
    }): Promise<void>;
    removeWorkspace({ workspaceId }: {
        workspaceId: string;
    }): Promise<void>;
    getProjects({ workspaceId }: {
        workspaceId: string;
    }, { forceCacheRefresh }?: {
        forceCacheRefresh: boolean;
    }): Promise<Project[]>;
    createProject({ workspaceId, name, region, options, }: {
        workspaceId: string;
        name: string;
        region: string;
        options: {
            skipRefresh?: boolean;
        };
    }): Promise<{
        project: Project;
        database?: NewRemoteDatabase;
    }>;
    deleteProject({ workspaceId, id }: {
        workspaceId: string;
        id: string;
    } | Project): Promise<void>;
    private refreshProjects;
    getRemoteDatabases({ workspaceId, projectId, }: {
        workspaceId: string;
        projectId: string;
    }, { forceCacheRefresh }?: {
        forceCacheRefresh: boolean;
    }): Promise<RemoteDatabase[]>;
    getStoredRemoteDatabaseConnectionString({ workspaceId, projectId, databaseId, }: {
        workspaceId: string;
        projectId: string;
        databaseId: string;
    }): Promise<string | undefined>;
    createRemoteDatabaseConnectionString({ workspaceId, projectId, databaseId, }: {
        workspaceId: string;
        projectId: string;
        databaseId: string;
    }): Promise<string>;
    createRemoteDatabase({ workspaceId, projectId, name, region, options, }: {
        workspaceId: string;
        projectId: string;
        name: string;
        region: string;
        options: {
            skipRefresh?: boolean;
        };
    }): Promise<NewRemoteDatabase>;
    deleteRemoteDatabase({ workspaceId, projectId, id, }: {
        workspaceId: string;
        projectId: string;
        id: string;
    } | RemoteDatabase): Promise<void>;
    private refreshRemoteDatabases;
    private refreshLocalDatabases;
    getLocalDatabases(): Promise<LocalDatabase[]>;
    createLocalDatabase(args: {
        name: string;
    }): Promise<void>;
    startLocalDatabase(args: {
        pid: number;
        name: string;
    }): Promise<void>;
    deleteLocalDatabase(args: {
        pid: number;
        name: string;
        url: string;
    }): Promise<void>;
    stopLocalDatabase(args: {
        pid: number;
        url: string;
    }): Promise<void>;
    deployLocalDatabase(args: {
        name: string;
        url: string;
        projectId: string;
        workspaceId: string;
    }): Promise<void>;
}
