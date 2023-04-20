import {cloudEvent} from '@google-cloud/functions-framework'
import {pubSubEventHandler} from './pubSubEventHandler';

cloudEvent("pubSubEventHandler", pubSubEventHandler);

