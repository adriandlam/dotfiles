import { Uri } from 'vscode';
import { PrismaPostgresRepository } from '../PrismaPostgresRepository';
import { Auth } from '../management-api/auth';
/**
 * This function triggers the OAuth login flow by creating the necessary URL and opening the users browser.
 */
export declare const login: (ppgRepository: PrismaPostgresRepository, auth: Auth) => Promise<void>;
/**
 * This function is called when the extension receives the auth callback from the previously started login flow.
 */
export declare const handleAuthCallback: ({ uri, ppgRepository, auth, }: {
    uri: Uri;
    ppgRepository: PrismaPostgresRepository;
    auth: Auth;
}) => Promise<void>;
