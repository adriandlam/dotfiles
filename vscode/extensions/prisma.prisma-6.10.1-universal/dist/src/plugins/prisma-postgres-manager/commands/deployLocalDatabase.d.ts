import { LocalDatabase, PrismaPostgresRepository } from '../PrismaPostgresRepository';
export declare function deployLocalDatabase(ppgRepository: PrismaPostgresRepository, args: unknown): Promise<void>;
export declare function deployLocalDatabaseSalefy(ppgRepository: PrismaPostgresRepository, args: LocalDatabase): Promise<void>;
