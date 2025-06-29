import { LocalDatabase, PrismaPostgresRepository } from '../PrismaPostgresRepository';
export declare function deleteLocalDatabase(ppgRepository: PrismaPostgresRepository, args: unknown): Promise<void>;
export declare function deleteLocalDatabaseSafely(ppgRepository: PrismaPostgresRepository, args: LocalDatabase): Promise<void>;
