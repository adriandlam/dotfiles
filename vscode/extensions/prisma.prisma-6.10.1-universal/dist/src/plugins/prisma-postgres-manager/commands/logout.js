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
Object.defineProperty(exports, "__esModule", { value: true });
exports.logout = void 0;
const PrismaPostgresRepository_1 = require("../PrismaPostgresRepository");
const pickWorkspace_1 = require("../shared-ui/pickWorkspace");
const logout = (ppgRepository, args) => __awaiter(void 0, void 0, void 0, function* () {
    let workspaceId;
    if ((0, PrismaPostgresRepository_1.isWorkspace)(args)) {
        workspaceId = args.id;
    }
    else {
        workspaceId = (yield (0, pickWorkspace_1.pickWorkspace)(ppgRepository)).id;
    }
    yield ppgRepository.removeWorkspace({ workspaceId });
});
exports.logout = logout;
//# sourceMappingURL=logout.js.map