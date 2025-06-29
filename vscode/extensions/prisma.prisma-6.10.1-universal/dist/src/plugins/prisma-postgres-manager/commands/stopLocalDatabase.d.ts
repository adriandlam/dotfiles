import { LocalDatabase, PrismaPostgresRepository } from '../PrismaPostgresRepository';
export declare function stopLocalDatabase(ppgRepository: PrismaPostgresRepository, args: unknown): Promise<void>;
export declare function stopLocalDatabaseSafely(ppgRepository: PrismaPostgresRepository, args: LocalDatabase): Promise<void>;
