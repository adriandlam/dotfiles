import { LocalDatabase, PrismaPostgresRepository } from '../PrismaPostgresRepository';
export declare function startLocalDatabase(ppgRepository: PrismaPostgresRepository, args: unknown): Promise<void>;
export declare function startLocalDatabaseSafely(ppgRepository: PrismaPostgresRepository, args: LocalDatabase): Promise<void>;
