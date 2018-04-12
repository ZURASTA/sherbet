defmodule Sherbet.Service.Contact do
    use GenServer

    alias Sherbet.Service.Contact.Communication

    def child_spec(_args) do
        %{
            id: __MODULE__,
            start: { __MODULE__, :start_link, [] },
            type: :worker
        }
    end

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def handle_call({ :add, { type, contact }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.add(type, contact, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :add, { type, contact, priority }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.add(type, contact, priority, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :remove, { type, contact }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.remove(type, contact, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :set_priority, { type, contact, priority }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.set_priority(type, contact, priority, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :request_removal, { type, contact } }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.request_removal(type, contact)) end)
        { :noreply, state }
    end
    def handle_call({ :finalise_removal, { type, contact, key } }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.finalise_removal(type, contact, key)) end)
        { :noreply, state }
    end
    def handle_call({ :verified?, { type, contact }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.verified?(type, contact, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :request_verification, { type, contact }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.request_verification(type, contact, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :finalise_verification, { type, contact, key }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.finalise_verification(type, contact, key, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :contacts, { type }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.contacts(type, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :primary_contact, { type }, identity }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.primary_contact(type, identity)) end)
        { :noreply, state }
    end
    def handle_call({ :owner, { type, contact } }, from, state) do
        Task.start(fn -> GenServer.reply(from, Communication.owner(type, contact)) end)
        { :noreply, state }
    end
    def handle_call({ :swarm, :begin_handoff }, _from, state), do: { :reply, :restart, state }

    def handle_cast({ :swarm, :end_handoff }, state), do: { :noreply, state }
    def handle_cast({ :swarm, :resolve_conflict, _state }, state), do: { :noreply, state }

    def handle_info({ :swarm, :die }, state), do: { :stop, :shutdown, state }
end
