defmodule Graft.Client do
    def send_job(server, job) do
        send server, job
    end
end
