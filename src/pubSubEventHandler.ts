import {CloudEventV1 as CloudEvent} from "cloudevents";

export const pubSubEventHandler = <T>(cloudEvent: CloudEvent<T>) => {
    console.log(`Received message with id ${cloudEvent.id}`);
}