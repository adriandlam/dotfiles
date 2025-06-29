import type { LanguageModelTool, ProviderResult, PreparedToolInvocation, CancellationToken, LanguageModelToolInvocationPrepareOptions } from 'vscode';
import { LanguageModelToolResult } from 'vscode';
export declare class PDPAuthLoginTool implements LanguageModelTool<void> {
    invoke(): LanguageModelToolResult;
    prepareInvocation(_options: LanguageModelToolInvocationPrepareOptions<void>, _token: CancellationToken): ProviderResult<PreparedToolInvocation>;
}
