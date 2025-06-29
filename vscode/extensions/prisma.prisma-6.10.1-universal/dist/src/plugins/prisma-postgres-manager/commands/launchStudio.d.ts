import { ExtensionContext } from 'vscode';
import { PrismaPostgresRepository } from '../PrismaPostgresRepository';
import { z } from 'zod';
export declare const LaunchArgLocalSchema: z.ZodObject<{
    type: z.ZodLiteral<"local">;
    id: z.ZodString;
    name: z.ZodString;
    url: z.ZodString;
    pid: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    type: "local";
    id: string;
    name: string;
    url: string;
    pid: number;
}, {
    type: "local";
    id: string;
    name: string;
    url: string;
    pid: number;
}>;
export type LaunchArgLocal = z.infer<typeof LaunchArgLocalSchema>;
export declare const LaunchArgRemoteSchema: z.ZodObject<{
    type: z.ZodLiteral<"remote">;
    workspaceId: z.ZodString;
    projectId: z.ZodString;
    databaseId: z.ZodString;
}, "strip", z.ZodTypeAny, {
    type: "remote";
    workspaceId: string;
    projectId: string;
    databaseId: string;
}, {
    type: "remote";
    workspaceId: string;
    projectId: string;
    databaseId: string;
}>;
export type LaunchArgRemote = z.infer<typeof LaunchArgRemoteSchema>;
export declare const launchStudio: ({ ppgRepository, context, args, }: {
    ppgRepository: PrismaPostgresRepository;
    context: ExtensionContext;
    args: unknown;
}) => Promise<void>;
