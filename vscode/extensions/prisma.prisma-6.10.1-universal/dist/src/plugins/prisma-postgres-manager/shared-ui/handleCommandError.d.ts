export declare class CommandAbortError extends Error {
    constructor(message: string);
}
export declare const handleCommandError: <T>(cmdTitle: string, cmd: () => Promise<T>) => Promise<T | null>;
