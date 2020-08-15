defmodule GraftTest do
    use ExUnit.Case
    
    setup_all do
        cluster = Application.fetch_env! :graft, :cluster
        %{cluster: cluster}
    end

    setup %{cluster: cluster} do
        for {server, _} <- cluster do
            Graft.restart_server server
        end
        
        on_exit fn ->
            for {server, _} <- cluster do
                Graft.restart_server server
            end
        end
        
        :ok
    end

    test "forcing a leader" do
        Graft.force_promotion :s1
        assert {:s1, node()} == Graft.leader :s1
        assert {:s1, node()} == Graft.leader :s2
        assert {:s1, node()} == Graft.leader :s3
    end
end
