import { Uri } from 'vscode';
export type AuthResult = {
    token: string;
    refreshToken: string;
};
export declare class AuthError extends Error {
    constructor(message: string);
}
export declare class Auth {
    private readonly extensionId;
    private latestVerifier?;
    private latestState?;
    constructor(extensionId: string);
    login(): Promise<void>;
    handleCallback(uri: Uri): Promise<AuthResult | null>;
    refreshToken(refreshToken: string): Promise<AuthResult>;
    private parseTokenResponse;
    private getRedirectUri;
    private base64urlEncode;
    private generateState;
    private generateVerifier;
    private generateChallenge;
}
