defmodule Sherbet.Service.Contact do
    use GenServer

    alias Sherbet.Service.Contact.Communication

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def handle_call({ :add, { type, contact }, identity }, _from, state), do: { :reply, Communication.add(type, contact, identity), state }
    def handle_call({ :add, { type, contact, priority }, identity }, _from, state), do: { :reply, Communication.add(type, contact, priority, identity), state }
    def handle_call({ :remove, { type, contact }, identity }, _from, state), do: { :reply, Communication.remove(type, contact, identity), state }
    def handle_call({ :set_priority, { type, contact, priority }, identity }, _from, state), do: { :reply, Communication.set_priority(type, contact, priority, identity), state }
    def handle_call({ :request_removal, { type, contact } }, _from, state), do: { :reply, Communication.request_removal(type, contact), state }
    def handle_call({ :finalise_removal, { type, contact, key } }, _from, state), do: { :reply, Communication.finalise_removal(type, contact, key), state }
    def handle_call({ :verified?, { type, contact }, identity }, _from, state), do: { :reply, Communication.verified?(type, contact, identity), state }
    def handle_call({ :request_verification, { type, contact }, identity }, _from, state), do: { :reply, Communication.request_verification(type, contact, identity), state }
    def handle_call({ :finalise_verification, { type, contact, key }, identity }, _from, state), do: { :reply, Communication.finalise_verification(type, contact, key, identity), state }
    def handle_call({ :contacts, { type }, identity }, _from, state), do: { :reply, Communication.contacts(type, identity), state }
    def handle_call({ :primary_contact, { type }, identity }, _from, state), do: { :reply, Communication.primary_contact(type, identity), state }
end
