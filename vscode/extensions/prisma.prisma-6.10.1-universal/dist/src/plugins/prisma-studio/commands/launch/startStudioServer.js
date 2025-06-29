"use strict";
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
exports.startStudioServer = startStudioServer;
const vscode_1 = require("vscode");
const hono_1 = require("hono");
const cors_1 = require("hono/cors"); // Import the cors middleware
const path_1 = __importDefault(require("path"));
const promises_1 = require("fs/promises");
const get_port_1 = __importDefault(require("get-port"));
const node_server_1 = require("@hono/node-server");
const accelerate_1 = require("@prisma/studio-core/data/accelerate");
const bff_1 = require("@prisma/studio-core/data/bff");
/**
 * Starts a local server for Prisma Studio and serves the UI files.
 * @param args - An object containing the static files root URI.
 * @returns The URL of the running server.
 */
function startStudioServer(args) {
    return __awaiter(this, void 0, void 0, function* () {
        const { dbUrl, context } = args;
        const staticFilesPath = ['node_modules', '@prisma', 'studio-core'];
        const staticFilesRoot = vscode_1.Uri.joinPath(context.extensionUri, ...staticFilesPath);
        const app = new hono_1.Hono();
        app.use('*', (0, cors_1.cors)());
        // gives access to accelerate (and more soon) via bff client
        app.post('/bff', (c) => __awaiter(this, void 0, void 0, function* () {
            var _a;
            const { query } = (yield c.req.json());
            const [error, results] = yield (0, accelerate_1.createAccelerateHttpClient)({
                host: new URL(dbUrl).host,
                apiKey: (_a = new URL(dbUrl).searchParams.get('api_key')) !== null && _a !== void 0 ? _a : '',
                // TODO: these need to be dynamic based on the vscode build
                engineHash: '81e4af48011447c3cc503a190e86995b66d2a28e',
                clientVersion: '6.9.0',
                provider: 'postgres',
            }).execute(query);
            if (error) {
                return c.json([(0, bff_1.serializeError)(error)]);
            }
            return c.json([null, results]);
        }));
        // gives access to client side rendering resources
        app.get('/*', (c) => __awaiter(this, void 0, void 0, function* () {
            var _a;
            const reqPath = c.req.path.substring(1);
            const filePath = path_1.default.join(staticFilesRoot.path, reqPath);
            const fileExt = path_1.default.extname(filePath).toLowerCase();
            const contentTypeMap = {
                '.css': 'text/css',
                '.js': 'application/javascript',
                '.mjs': 'application/javascript',
                '.html': 'text/html',
                '.htm': 'text/html',
                '.json': 'application/json',
                '.png': 'image/png',
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg',
                '.gif': 'image/gif',
                '.svg': 'image/svg+xml',
            };
            const contentType = (_a = contentTypeMap[fileExt]) !== null && _a !== void 0 ? _a : 'application/octet-stream';
            try {
                return c.body(yield (0, promises_1.readFile)(filePath), 200, { 'Content-Type': contentType });
            }
            catch (error) {
                return c.text('File not found', 404);
            }
        }));
        const port = yield (0, get_port_1.default)();
        const serverUrl = `http://localhost:${port}`;
        const server = (0, node_server_1.serve)({ fetch: app.fetch, port, overrideGlobalObjects: false }, () => {
            console.log(`Studio server is running at ${serverUrl}`);
        });
        return { server, url: serverUrl };
    });
}
//# sourceMappingURL=startStudioServer.js.map