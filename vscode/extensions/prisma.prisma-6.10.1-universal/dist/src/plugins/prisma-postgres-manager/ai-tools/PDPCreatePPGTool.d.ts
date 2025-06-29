import type { LanguageModelToolInvocationOptions, LanguageModelTool, ProviderResult, PreparedToolInvocation, CancellationToken, LanguageModelToolInvocationPrepareOptions } from 'vscode';
import { LanguageModelToolResult } from 'vscode';
import { PrismaPostgresRepository } from '../PrismaPostgresRepository';
type PDPCreatePPGToolInput = {
    name: string;
    workspaceId?: string;
    regionId?: string;
};
export declare class PDPCreatePPGTool implements LanguageModelTool<PDPCreatePPGToolInput> {
    private readonly ppgRepository;
    constructor(ppgRepository: PrismaPostgresRepository);
    invoke(options: LanguageModelToolInvocationOptions<PDPCreatePPGToolInput>, _cancelToken: CancellationToken): Promise<LanguageModelToolResult>;
    prepareInvocation(options: LanguageModelToolInvocationPrepareOptions<PDPCreatePPGToolInput>, _token: CancellationToken): ProviderResult<PreparedToolInvocation>;
}
export {};
