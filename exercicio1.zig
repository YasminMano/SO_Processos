const std = @import("std");
const linux = std.os.linux;

pub fn main(init: std.process.Init) void {
    const args = init.minimal.args.toSlice(
        init.arena.allocator(),
    ) catch {
        std.debug.print("Erro ao ler argumentos.\n", .{});
        return;
    };

    if (args.len < 2) {
        std.debug.print(
            "Uso: ./exercicio1 orfao | zumbi\n",
            .{},
        );
        return;
    }

    const opcao = args[1];

    if (std.mem.eql(u8, opcao, "orfao")) {
        criarOrfao();
    } else if (std.mem.eql(u8, opcao, "zumbi")) {
        criarZumbi();
    } else {
        std.debug.print("Opcao invalida.\n", .{});
    }
}

fn criarOrfao() void {
    const pid = linux.fork();

    if (pid == 0) {
        std.debug.print(
            "FILHO: Meu PID e {}\n",
            .{linux.getpid()},
        );

        std.debug.print(
            "FILHO: Meu PPID atual e {}\n",
            .{linux.getppid()},
        );

        _ = linux.nanosleep(
            &linux.timespec{ .sec = 5, .nsec = 0 },
            null,
        );

        std.debug.print(
            "FILHO: Depois de 5 segundos, meu PPID e {}\n",
            .{linux.getppid()},
        );

        linux.exit(0);
    } else {
        std.debug.print(
            "PAI: Meu PID e {}\n",
            .{linux.getpid()},
        );

        std.debug.print(
            "PAI: Criei o filho {} e vou terminar.\n",
            .{pid},
        );

        linux.exit(0);
    }
}

fn criarZumbi() void {
    const pid = linux.fork();

    if (pid == 0) {
        std.debug.print(
            "FILHO: Meu PID e {}\n",
            .{linux.getpid()},
        );

        std.debug.print(
            "FILHO: Encerrando agora.\n",
            .{},
        );

        linux.exit(0);
    } else {
        std.debug.print(
            "PAI: Meu PID e {}\n",
            .{linux.getpid()},
        );

        std.debug.print(
            "PAI: Filho criado com PID {}\n",
            .{pid},
        );

        std.debug.print(
            "PAI: Esperando 15 segundos sem waitpid().\n",
            .{},
        );

        _ = linux.nanosleep(
            &linux.timespec{ .sec = 15, .nsec = 0 },
            null,
        );

        std.debug.print(
            "PAI: Encerrando.\n",
            .{},
        );

        linux.exit(0);
    }
}
