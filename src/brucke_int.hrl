%%%
%%%   Copyright (c) 2016 Klarna AB
%%%
%%%   Licensed under the Apache License, Version 2.0 (the "License");
%%%   you may not use this file except in compliance with the License.
%%%   You may obtain a copy of the License at
%%%
%%%       http://www.apache.org/licenses/LICENSE-2.0
%%%
%%%   Unless required by applicable law or agreed to in writing, software
%%%   distributed under the License is distributed on an "AS IS" BASIS,
%%%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%%   See the License for the specific language governing permissions and
%%%   limitations under the License.
%%%

-ifndef(BRUCKE_INT_HRL).
-define(BRUCKE_INT_HRL, true).

-include_lib("brod/include/brod.hrl").

-define(undef, undefined).

-type filename() :: string().

-type route_option_key() :: repartitioning_strategy
                          | producer_config
                          | consumer_config
                          | max_partitions_per_group_member.

%% Message repartitioning strategy.
%% NOTE: For compacted topics, strict_p2p is the only choice.
%% key_hash:
%%   Hash the message key to downstream partition number
%% strict_p2p:
%%   Strictly map the upstream partition number to downstream partition
%%   number, worker will refuse to start if upstream and downstream
%%   topic has different number of partitions
%% random:
%%   Randomly distribute upstream messages to downstream partitions
-type repartitioning_strategy() :: key_hash
                                 | strict_p2p
                                 | random.

-define(DEFAULT_REPARTITIONING_STRATEGY, key_hash).

-define(IS_VALID_REPARTITIONING_STRATEGY(X),
        (X =:= key_hash orelse
         X =:= strict_p2p orelse
         X =:= random)).

-define(MAX_PARTITIONS_PER_GROUP_MEMBER, 12).

-type consumer_group_id() :: binary().
-type hostname() :: string().
-type portnum() :: pos_integer().
-type endpoint() :: {hostname(), portnum()}.
-type cluster_name() :: binary().
-type cluster() :: {cluster_name(), [endpoint()]}.
-type client() :: {brod_client_id(), [endpoint()], brod_client_config()}.
-type route_options() :: [{route_option_key(), term()}]
                       | #{route_option_key() => term()}.
-type topic_name() :: atom() | string() | binary().


%% brucke route input is a eterm of below spec:
%% [{ {UpstreamGroupName :: atom(), [UpstreamTopic :: topic_name()]},
%%  , {DownstreamClientName :: atom(), DownstreamTopic :: topic_name()}
%%  , #{ repartitioning_strategy => repartitioning_strategy()
%%     , producer_config => [...] %% see brod for details
%%     , consumer_config => [...] %% see brod for details
%%       %% maximum number of partitions a subscriber can subscribe to
%%     , max_partitions_per_subscriber => 60
%%     }
%%  }]
%% The route entries are converted into an ets table which acts as a routing
%% cache. i.e. When a message is received from upstream topic, do a lookup
%% in the routing table, then send it to the downstream producer.
-type raw_route() :: { Upstream   :: {brod_client_id(), topic_name()
                                   | [topic_name()]}
                     , Downstream :: {brod_client_id(), topic_name()}
                     , Options    :: route_options()
                     }.

-type route() :: { Upstream   :: {brod_client_id(), kafka_topic()}
                 , Downstream :: {brod_client_id(), kafka_topic()}
                 , Options    :: route_options()
                 }.

-endif.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End: