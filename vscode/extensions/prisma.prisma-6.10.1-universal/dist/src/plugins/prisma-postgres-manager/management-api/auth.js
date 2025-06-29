"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Auth = exports.AuthError = void 0;
const crypto = __importStar(require("crypto"));
const vscode_1 = require("vscode");
const zod_1 = __importDefault(require("zod"));
const CLIENT_ID = 'cmamnw2go00005812nlbzb4pi';
const LOGIN_URL = 'https://auth.prisma.io/authorize';
const TOKEN_URL = 'https://auth.prisma.io/token';
class AuthError extends Error {
    constructor(message) {
        super(message);
        this.name = 'AuthError';
    }
}
exports.AuthError = AuthError;
class Auth {
    constructor(extensionId) {
        this.extensionId = extensionId;
    }
    login() {
        return __awaiter(this, void 0, void 0, function* () {
            this.latestState = this.generateState();
            this.latestVerifier = this.generateVerifier();
            const challenge = this.generateChallenge(this.latestVerifier);
            const authUrl = new URL(LOGIN_URL);
            authUrl.searchParams.set('response_type', 'code');
            authUrl.searchParams.set('client_id', CLIENT_ID);
            authUrl.searchParams.set('redirect_uri', this.getRedirectUri());
            authUrl.searchParams.set('scope', 'workspace:admin offline_access');
            authUrl.searchParams.set('state', this.latestState);
            authUrl.searchParams.set('code_challenge', challenge);
            authUrl.searchParams.set('code_challenge_method', 'S256');
            authUrl.searchParams.set('utm_source', 'extension');
            yield vscode_1.env.openExternal(vscode_1.Uri.parse(authUrl.toString()));
        });
    }
    handleCallback(uri) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log('handleCallback', uri);
            if (uri.path !== '/auth/callback')
                return null;
            const params = new URLSearchParams(uri.query);
            const error = params.get('error');
            if (error)
                throw new AuthError(error);
            const code = params.get('code');
            const state = params.get('state');
            if (!code)
                throw new AuthError('No code found in callback');
            if (!this.latestVerifier)
                throw new AuthError('No verifier found');
            if (state !== this.latestState)
                throw new AuthError('Invalid state');
            const body = new URLSearchParams({
                grant_type: 'authorization_code',
                code,
                redirect_uri: this.getRedirectUri(),
                client_id: CLIENT_ID,
                code_verifier: this.latestVerifier,
            });
            const response = yield fetch(TOKEN_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body,
            });
            return this.parseTokenResponse(response);
        });
    }
    refreshToken(refreshToken) {
        return __awaiter(this, void 0, void 0, function* () {
            const body = new URLSearchParams({
                grant_type: 'refresh_token',
                refresh_token: refreshToken,
                client_id: CLIENT_ID,
            });
            const response = yield fetch(TOKEN_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body,
            });
            const result = yield this.parseTokenResponse(response);
            return result;
        });
    }
    parseTokenResponse(response) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield response.json();
            if (response.status !== 200)
                throw new AuthError(`Failed to get token. Status code ${response.status}.`);
            const parsed = zod_1.default
                .object({
                access_token: zod_1.default.string(),
                refresh_token: zod_1.default.string(),
            })
                .parse(data);
            return { token: parsed.access_token, refreshToken: parsed.refresh_token };
        });
    }
    getRedirectUri() {
        return `${vscode_1.env.uriScheme}://${this.extensionId.toLowerCase()}/auth/callback`;
    }
    base64urlEncode(buffer) {
        return buffer.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
    }
    generateState() {
        return crypto.randomBytes(16).toString('hex');
    }
    generateVerifier() {
        return this.base64urlEncode(crypto.randomBytes(32));
    }
    generateChallenge(verifier) {
        const hash = crypto.createHash('sha256').update(verifier).digest();
        return this.base64urlEncode(hash);
    }
}
exports.Auth = Auth;
//# sourceMappingURL=auth.js.map