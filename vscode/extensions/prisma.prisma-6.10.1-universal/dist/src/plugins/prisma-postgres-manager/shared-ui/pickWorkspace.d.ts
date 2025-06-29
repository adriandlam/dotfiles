import { PrismaPostgresRepository } from '../PrismaPostgresRepository';
export declare const pickWorkspace: (ppgRepository: PrismaPostgresRepository) => Promise<{
    type: "workspace";
    id: string;
    name: string;
}>;
