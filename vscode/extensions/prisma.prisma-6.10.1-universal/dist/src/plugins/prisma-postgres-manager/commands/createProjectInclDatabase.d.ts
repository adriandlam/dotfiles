import { PrismaPostgresRepository } from '../PrismaPostgresRepository';
import z from 'zod';
export declare const CreateProjectInclDatabaseArgsSchema: z.ZodUnion<[z.ZodObject<{
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
}>, z.ZodUndefined]>;
export type CreateProjectInclDatabaseArgs = z.infer<typeof CreateProjectInclDatabaseArgsSchema>;
export declare const createProjectInclDatabase: (ppgRepository: PrismaPostgresRepository, args: unknown, options: {
    skipRefresh?: boolean;
}) => Promise<{
    project: import("../PrismaPostgresRepository").Project;
    database?: import("../PrismaPostgresRepository").NewRemoteDatabase;
}>;
export declare const createProjectInclDatabaseSafely: (ppgRepository: PrismaPostgresRepository, args: CreateProjectInclDatabaseArgs, options: {
    skipRefresh?: boolean;
}) => Promise<{
    project: import("../PrismaPostgresRepository").Project;
    database?: import("../PrismaPostgresRepository").NewRemoteDatabase;
}>;
