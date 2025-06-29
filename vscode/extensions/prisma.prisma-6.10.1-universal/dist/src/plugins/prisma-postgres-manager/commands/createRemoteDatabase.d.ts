import { PrismaPostgresRepository } from '../PrismaPostgresRepository';
import z from 'zod';
export declare const CreateRemoteDatabaseArgsSchema: z.ZodUnion<[z.ZodObject<{
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
}>, z.ZodUndefined]>;
export type CreateRemoteDatabaseArgs = z.infer<typeof CreateRemoteDatabaseArgsSchema>;
export declare const createRemoteDatabase: (ppgRepository: PrismaPostgresRepository, args: unknown, options: {
    skipRefresh?: boolean;
}) => Promise<{
    project: import("../PrismaPostgresRepository").Project;
    database?: import("../PrismaPostgresRepository").NewRemoteDatabase;
} | {
    project: {
        workspaceId: string;
        id: string;
    };
    database: import("../PrismaPostgresRepository").NewRemoteDatabase;
} | undefined>;
export declare const createRemoteDatabaseSafely: (ppgRepository: PrismaPostgresRepository, args: CreateRemoteDatabaseArgs, options: {
    skipRefresh?: boolean;
}) => Promise<{
    project: import("../PrismaPostgresRepository").Project;
    database?: import("../PrismaPostgresRepository").NewRemoteDatabase;
} | {
    project: {
        workspaceId: string;
        id: string;
    };
    database: import("../PrismaPostgresRepository").NewRemoteDatabase;
} | undefined>;
