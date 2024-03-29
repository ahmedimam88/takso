{application,cowboy,
             [{description,"Small, fast, modular HTTP server."},
              {vsn,"1.1.2"},
              {id,"git"},
              {modules,[cow_uri,cowboy,cowboy_app,cowboy_bstr,cowboy_clock,
                        cowboy_handler,cowboy_http,cowboy_http_handler,
                        cowboy_loop_handler,cowboy_middleware,cowboy_req,
                        cowboy_rest,cowboy_router,cowboy_spdy,cowboy_static,
                        cowboy_sub_protocol,cowboy_sup,cowboy_websocket,
                        cowboy_websocket_handler]},
              {registered,[cowboy_clock,cowboy_sup]},
              {applications,[kernel,stdlib,ranch,cowlib,crypto]},
              {mod,{cowboy_app,[]}},
              {env,[]}]}.
