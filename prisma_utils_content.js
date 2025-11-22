"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prisma = exports.prismaManager = void 0;
const client_1 = require("@prisma/client");
const async_mutex_1 = require("async-mutex");
class PrismaManager {
    constructor() {
        this.MAX_CONNECTIONS = 10;
        this.activeConnections = new Set();
        this.prisma = new client_1.PrismaClient({
            log: ["query", "info", "warn", "error"],
            datasources: {
                db: {
                    url: process.env.DATABASE_URL,
                },
            },
        });
        this.semaphore = new async_mutex_1.Semaphore(this.MAX_CONNECTIONS);
    }
    static getInstance() {
        if (!PrismaManager.instance) {
            PrismaManager.instance = new PrismaManager();
        }
        return PrismaManager.instance;
    }
    async getClient() {
        const [, release] = await this.semaphore.acquire();
        const connectionId = Math.random().toString(36).substring(7);
        this.activeConnections.add(connectionId);
        return {
            client: this.prisma,
            release: () => {
                this.activeConnections.delete(connectionId);
                release();
            },
        };
    }
    getActiveConnectionsCount() {
        return this.activeConnections.size;
    }
    async disconnect() {
        await this.prisma.$disconnect();
    }
    // Middleware để tự động release connection sau timeout
    async withConnection(operation) {
        const { client, release } = await this.getClient();
        try {
            const result = await Promise.race([
                operation(client),
                new Promise((_, reject) => setTimeout(() => reject(new Error("Database operation timeout")), 30000)),
            ]);
            return result;
        }
        finally {
            release();
        }
    }
}
exports.prismaManager = PrismaManager.getInstance();
// Export direct prisma instance for repositories
exports.prisma = exports.prismaManager['prisma'];
//# sourceMappingURL=prisma.js.map