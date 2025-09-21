import ballerina/grpc;
import ballerina/protobuf;

public const string CARRENTAL_DESC = "0A1670726F746F732F63617272656E74616C2E70726F746F120F63617272656E74616C73797374656D22D2030A0343617212140A05706C6174651801200128095205706C61746512120A046D616B6518022001280952046D616B6512140A056D6F64656C18032001280952056D6F64656C12120A0479656172180420012805520479656172121F0A0B6461696C795F7072696365180520012801520A6461696C79507269636512180A076D696C6561676518062001280552076D696C6561676512320A0673746174757318072001280E321A2E63617272656E74616C73797374656D2E436172537461747573520673746174757312140A05636F6C6F721808200128095205636F6C6F72121B0A096675656C5F7479706518092001280952086675656C5479706512290A1073656174696E675F6361706163697479180A20012805520F73656174696E67436170616369747912220A0C7472616E736D697373696F6E180B20012809520C7472616E736D697373696F6E121A0A086665617475726573180C2003280952086665617475726573121A0A086C6F636174696F6E180D2001280952086C6F636174696F6E122B0A11637265617465645F74696D657374616D70180E2001280352106372656174656454696D657374616D7012210A0C6C6173745F75706461746564180F20012803520B6C6173745570646174656422BE020A045573657212170A07757365725F69641801200128095206757365724964121A0A08757365726E616D651802200128095208757365726E616D6512140A05656D61696C1803200128095205656D61696C12140A0570686F6E65180420012809520570686F6E65122D0A04726F6C6518052001280E32192E63617272656E74616C73797374656D2E55736572526F6C655204726F6C65121B0A0966756C6C5F6E616D65180620012809520866756C6C4E616D6512180A076164647265737318072001280952076164647265737312250A0E6C6963656E73655F6E756D626572180820012809520D6C6963656E73654E756D626572122B0A11637265617465645F74696D657374616D7018092001280352106372656174656454696D657374616D70121B0A0969735F616374697665180A200128085208697341637469766522CD010A08436172744974656D12140A05706C6174651801200128095205706C617465121D0A0A73746172745F64617465180220012809520973746172744461746512190A08656E645F646174651803200128095207656E644461746512270A0F657374696D617465645F7072696365180420012801520E657374696D617465645072696365121F0A0B72656E74616C5F64617973180520012805520A72656E74616C4461797312270A0F61646465645F74696D657374616D70180620012803520E616464656454696D657374616D7022F5030A125265736572766174696F6E44657461696C7312250A0E7265736572766174696F6E5F6964180120012809520D7265736572766174696F6E496412170A07757365725F6964180220012809520675736572496412140A05706C6174651803200128095205706C617465121D0A0A73746172745F64617465180420012809520973746172744461746512190A08656E645F646174651805200128095207656E6444617465121F0A0B746F74616C5F7072696365180620012801520A746F74616C5072696365121F0A0B72656E74616C5F64617973180720012805520A72656E74616C44617973123A0A0673746174757318082001280E32222E63617272656E74616C73797374656D2E5265736572766174696F6E5374617475735206737461747573122B0A11637265617465645F74696D657374616D7018092001280352106372656174656454696D657374616D7012210A0C6C6173745F75706461746564180A20012803520B6C6173745570646174656412230A0D637573746F6D65725F6E616D65180B20012809520C637573746F6D65724E616D6512250A0E637573746F6D65725F656D61696C180C20012809520D637573746F6D6572456D61696C12350A0B6361725F64657461696C73180D2001280B32142E63617272656E74616C73797374656D2E436172520A63617244657461696C73225B0A0D4164644361725265717565737412220A0D61646D696E5F757365725F6964180120012809520B61646D696E55736572496412260A0363617218022001280B32142E63617272656E74616C73797374656D2E4361725203636172225B0A0E416464436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512150A066361725F696418032001280952056361724964223E0A11437265617465557365725265717565737412290A047573657218012001280B32152E63617272656E74616C73797374656D2E557365725204757365722296010A134372656174655573657273526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512230A0D75736572735F63726561746564180320012805520C75736572734372656174656412260A0F6661696C65645F757365725F696473180420032809520D6661696C6564557365724964732283010A105570646174654361725265717565737412220A0D61646D696E5F757365725F6964180120012809520B61646D696E55736572496412140A05706C6174651802200128095205706C61746512350A0B757064617465645F63617218032001280B32142E63617272656E74616C73797374656D2E436172520A75706461746564436172227E0A11557064617465436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512350A0B757064617465645F63617218032001280B32142E63617272656E74616C73797374656D2E436172520A75706461746564436172224C0A1052656D6F76654361725265717565737412220A0D61646D696E5F757365725F6964180120012809520B61646D696E55736572496412140A05706C6174651802200128095205706C6174652284010A1152656D6F7665436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D657373616765123B0A0E72656D61696E696E675F6361727318032003280B32142E63617272656E74616C73797374656D2E436172520D72656D61696E696E67436172732283010A174C6973745265736572766174696F6E735265717565737412220A0D61646D696E5F757365725F6964180120012809520B61646D696E55736572496412230A0D66696C7465725F737461747573180220012809520C66696C746572537461747573121F0A0B66696C7465725F64617465180320012809520A66696C7465724461746522AE010A184C697374417661696C61626C65436172735265717565737412170A07757365725F69641801200128095206757365724964121F0A0B66696C7465725F74657874180220012809520A66696C74657254657874121F0A0B66696C7465725F79656172180320012805520A66696C74657259656172121B0A096D61785F707269636518042001280152086D61785072696365121A0A086C6F636174696F6E18052001280952086C6F636174696F6E22410A105365617263684361725265717565737412170A07757365725F6964180120012809520675736572496412140A05706C6174651802200128095205706C61746522B6010A11536561726368436172526573706F6E736512140A05666F756E641801200128085205666F756E64121C0A09617661696C61626C651802200128085209617661696C61626C6512260A0363617218032001280B32142E63617272656E74616C73797374656D2E436172520363617212180A076D65737361676518042001280952076D657373616765122B0A11756E617661696C61626C655F64617465731805200328095210756E617661696C61626C654461746573227B0A10416464546F436172745265717565737412170A07757365725F6964180120012809520675736572496412140A05706C6174651802200128095205706C617465121D0A0A73746172745F64617465180320012809520973746172744461746512190A08656E645F646174651804200128095207656E6444617465229C010A11416464546F43617274526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512360A09636172745F6974656D18032001280B32192E63617272656E74616C73797374656D2E436172744974656D5208636172744974656D121B0A09636172745F73697A6518042001280552086361727453697A652284010A17506C6163655265736572766174696F6E5265717565737412170A07757365725F6964180120012809520675736572496412250A0E7061796D656E745F6D6574686F64180220012809520D7061796D656E744D6574686F6412290A107370656369616C5F7265717565737473180320012809520F7370656369616C526571756573747322EB010A18506C6163655265736572766174696F6E526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512470A0C7265736572766174696F6E7318032003280B32232E63617272656E74616C73797374656D2E5265736572766174696F6E44657461696C73520C7265736572766174696F6E7312210A0C746F74616C5F616D6F756E74180420012801520B746F74616C416D6F756E74122F0A13636F6E6669726D6174696F6E5F6E756D6265721805200128095212636F6E6669726D6174696F6E4E756D62657222300A154765745573657250726F66696C655265717565737412170A07757365725F6964180120012809520675736572496422CD010A164765745573657250726F66696C65526573706F6E736512180A077375636365737318012001280852077375636365737312290A047573657218022001280B32152E63617272656E74616C73797374656D2E5573657252047573657212180A076D65737361676518032001280952076D65737361676512540A13726563656E745F7265736572766174696F6E7318042003280B32232E63617272656E74616C73797374656D2E5265736572766174696F6E44657461696C735212726563656E745265736572766174696F6E73222A0A0F56696577436172745265717565737412170A07757365725F6964180120012809520675736572496422D5010A105669657743617274526573706F6E736512180A077375636365737318012001280852077375636365737312380A0A636172745F6974656D7318022003280B32192E63617272656E74616C73797374656D2E436172744974656D5209636172744974656D7312320A15746F74616C5F657374696D617465645F70726963651803200128015213746F74616C457374696D617465645072696365121F0A0B746F74616C5F6974656D73180420012805520A746F74616C4974656D7312180A076D65737361676518052001280952076D6573736167652A4E0A09436172537461747573120D0A09415641494C41424C451000120F0A0B554E415641494C41424C45100112150A11554E4445525F4D41494E54454E414E43451002120A0A0652454E54454410032A230A0855736572526F6C65120C0A08435553544F4D4552100012090A0541444D494E10012A4D0A115265736572766174696F6E537461747573120B0A0750454E44494E471000120D0A09434F4E4649524D45441001120D0A09434F4D504C455445441002120D0A0943414E43454C4C4544100332E5070A1043617252656E74616C5365727669636512490A06416464436172121E2E63617272656E74616C73797374656D2E416464436172526571756573741A1F2E63617272656E74616C73797374656D2E416464436172526573706F6E736512590A0B437265617465557365727312222E63617272656E74616C73797374656D2E43726561746555736572526571756573741A242E63617272656E74616C73797374656D2E4372656174655573657273526573706F6E7365280112520A0955706461746543617212212E63617272656E74616C73797374656D2E557064617465436172526571756573741A222E63617272656E74616C73797374656D2E557064617465436172526573706F6E736512520A0952656D6F766543617212212E63617272656E74616C73797374656D2E52656D6F7665436172526571756573741A222E63617272656E74616C73797374656D2E52656D6F7665436172526573706F6E736512660A134C697374416C6C5265736572766174696F6E7312282E63617272656E74616C73797374656D2E4C6973745265736572766174696F6E73526571756573741A232E63617272656E74616C73797374656D2E5265736572766174696F6E44657461696C73300112560A114C697374417661696C61626C654361727312292E63617272656E74616C73797374656D2E4C697374417661696C61626C6543617273526571756573741A142E63617272656E74616C73797374656D2E436172300112520A0953656172636843617212212E63617272656E74616C73797374656D2E536561726368436172526571756573741A222E63617272656E74616C73797374656D2E536561726368436172526573706F6E736512520A09416464546F4361727412212E63617272656E74616C73797374656D2E416464546F43617274526571756573741A222E63617272656E74616C73797374656D2E416464546F43617274526573706F6E736512670A10506C6163655265736572766174696F6E12282E63617272656E74616C73797374656D2E506C6163655265736572766174696F6E526571756573741A292E63617272656E74616C73797374656D2E506C6163655265736572766174696F6E526573706F6E736512610A0E4765745573657250726F66696C6512262E63617272656E74616C73797374656D2E4765745573657250726F66696C65526571756573741A272E63617272656E74616C73797374656D2E4765745573657250726F66696C65526573706F6E7365124F0A08566965774361727412202E63617272656E74616C73797374656D2E5669657743617274526571756573741A212E63617272656E74616C73797374656D2E5669657743617274526573706F6E7365620670726F746F33";

public isolated client class CarRentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CARRENTAL_DESC);
    }

    isolated remote function AddCar(AddCarRequest|ContextAddCarRequest req) returns AddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddCarResponse>result;
    }

    isolated remote function AddCarContext(AddCarRequest|ContextAddCarRequest req) returns ContextAddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddCarResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateCar(UpdateCarRequest|ContextUpdateCarRequest req) returns UpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdateCarResponse>result;
    }

    isolated remote function UpdateCarContext(UpdateCarRequest|ContextUpdateCarRequest req) returns ContextUpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdateCarResponse>result, headers: respHeaders};
    }

    isolated remote function RemoveCar(RemoveCarRequest|ContextRemoveCarRequest req) returns RemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemoveCarResponse>result;
    }

    isolated remote function RemoveCarContext(RemoveCarRequest|ContextRemoveCarRequest req) returns ContextRemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemoveCarResponse>result, headers: respHeaders};
    }

    isolated remote function SearchCar(SearchCarRequest|ContextSearchCarRequest req) returns SearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchCarResponse>result;
    }

    isolated remote function SearchCarContext(SearchCarRequest|ContextSearchCarRequest req) returns ContextSearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchCarResponse>result, headers: respHeaders};
    }

    isolated remote function AddToCart(AddToCartRequest|ContextAddToCartRequest req) returns AddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddToCartResponse>result;
    }

    isolated remote function AddToCartContext(AddToCartRequest|ContextAddToCartRequest req) returns ContextAddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddToCartResponse>result, headers: respHeaders};
    }

    isolated remote function PlaceReservation(PlaceReservationRequest|ContextPlaceReservationRequest req) returns PlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PlaceReservationResponse>result;
    }

    isolated remote function PlaceReservationContext(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ContextPlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PlaceReservationResponse>result, headers: respHeaders};
    }

    isolated remote function GetUserProfile(GetUserProfileRequest|ContextGetUserProfileRequest req) returns GetUserProfileResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetUserProfileRequest message;
        if req is ContextGetUserProfileRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/GetUserProfile", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <GetUserProfileResponse>result;
    }

    isolated remote function GetUserProfileContext(GetUserProfileRequest|ContextGetUserProfileRequest req) returns ContextGetUserProfileResponse|grpc:Error {
        map<string|string[]> headers = {};
        GetUserProfileRequest message;
        if req is ContextGetUserProfileRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/GetUserProfile", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <GetUserProfileResponse>result, headers: respHeaders};
    }

    isolated remote function ViewCart(ViewCartRequest|ContextViewCartRequest req) returns ViewCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        ViewCartRequest message;
        if req is ContextViewCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/ViewCart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ViewCartResponse>result;
    }

    isolated remote function ViewCartContext(ViewCartRequest|ContextViewCartRequest req) returns ContextViewCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        ViewCartRequest message;
        if req is ContextViewCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/ViewCart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ViewCartResponse>result, headers: respHeaders};
    }

    isolated remote function CreateUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("carrentalsystem.CarRentalService/CreateUsers");
        return new CreateUsersStreamingClient(sClient);
    }

    isolated remote function ListAllReservations(ListReservationsRequest|ContextListReservationsRequest req) returns stream<ReservationDetails, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListReservationsRequest message;
        if req is ContextListReservationsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrentalsystem.CarRentalService/ListAllReservations", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        ReservationDetailsStream outputStream = new ReservationDetailsStream(result);
        return new stream<ReservationDetails, grpc:Error?>(outputStream);
    }

    isolated remote function ListAllReservationsContext(ListReservationsRequest|ContextListReservationsRequest req) returns ContextReservationDetailsStream|grpc:Error {
        map<string|string[]> headers = {};
        ListReservationsRequest message;
        if req is ContextListReservationsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrentalsystem.CarRentalService/ListAllReservations", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        ReservationDetailsStream outputStream = new ReservationDetailsStream(result);
        return {content: new stream<ReservationDetails, grpc:Error?>(outputStream), headers: respHeaders};
    }

    isolated remote function ListAvailableCars(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns stream<Car, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrentalsystem.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        CarStream outputStream = new CarStream(result);
        return new stream<Car, grpc:Error?>(outputStream);
    }

    isolated remote function ListAvailableCarsContext(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns ContextCarStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrentalsystem.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        CarStream outputStream = new CarStream(result);
        return {content: new stream<Car, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendCreateUserRequest(CreateUserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextCreateUserRequest(ContextCreateUserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class ReservationDetailsStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|ReservationDetails value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|ReservationDetails value;|} nextRecord = {value: <ReservationDetails>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public class CarStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Car value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Car value;|} nextRecord = {value: <Car>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class CarRentalServiceRemoveCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRemoveCarResponse(RemoveCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRemoveCarResponse(ContextRemoveCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceReservationDetailsCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendReservationDetails(ReservationDetails response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextReservationDetails(ContextReservationDetails response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceSearchCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendSearchCarResponse(SearchCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextSearchCarResponse(ContextSearchCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceAddCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddCarResponse(AddCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddCarResponse(ContextAddCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCarCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCar(Car response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCar(ContextCar response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceAddToCartResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddToCartResponse(AddToCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddToCartResponse(ContextAddToCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServicePlaceReservationResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPlaceReservationResponse(PlaceReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPlaceReservationResponse(ContextPlaceReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceGetUserProfileResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendGetUserProfileResponse(GetUserProfileResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextGetUserProfileResponse(ContextGetUserProfileResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceViewCartResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendViewCartResponse(ViewCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextViewCartResponse(ContextViewCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCreateUsersResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCreateUsersResponse(CreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCreateUsersResponse(ContextCreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceUpdateCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUpdateCarResponse(UpdateCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUpdateCarResponse(ContextUpdateCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextCarStream record {|
    stream<Car, error?> content;
    map<string|string[]> headers;
|};

public type ContextReservationDetailsStream record {|
    stream<ReservationDetails, error?> content;
    map<string|string[]> headers;
|};

public type ContextCreateUserRequestStream record {|
    stream<CreateUserRequest, error?> content;
    map<string|string[]> headers;
|};

public type ContextViewCartRequest record {|
    ViewCartRequest content;
    map<string|string[]> headers;
|};

public type ContextListReservationsRequest record {|
    ListReservationsRequest content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationResponse record {|
    PlaceReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextGetUserProfileRequest record {|
    GetUserProfileRequest content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarRequest record {|
    RemoveCarRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarRequest record {|
    UpdateCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarResponse record {|
    AddCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartResponse record {|
    AddToCartResponse content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarResponse record {|
    UpdateCarResponse content;
    map<string|string[]> headers;
|};

public type ContextGetUserProfileResponse record {|
    GetUserProfileResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartRequest record {|
    AddToCartRequest content;
    map<string|string[]> headers;
|};

public type ContextListAvailableCarsRequest record {|
    ListAvailableCarsRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarRequest record {|
    SearchCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarRequest record {|
    AddCarRequest content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarResponse record {|
    RemoveCarResponse content;
    map<string|string[]> headers;
|};

public type ContextViewCartResponse record {|
    ViewCartResponse content;
    map<string|string[]> headers;
|};

public type ContextCar record {|
    Car content;
    map<string|string[]> headers;
|};

public type ContextReservationDetails record {|
    ReservationDetails content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationRequest record {|
    PlaceReservationRequest content;
    map<string|string[]> headers;
|};

public type ContextCreateUserRequest record {|
    CreateUserRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarResponse record {|
    SearchCarResponse content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ViewCartRequest record {|
    string user_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ListReservationsRequest record {|
    string admin_user_id = "";
    string filter_status = "";
    string filter_date = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type User record {|
    string user_id = "";
    string username = "";
    string email = "";
    string phone = "";
    UserRole role = CUSTOMER;
    string full_name = "";
    string address = "";
    string license_number = "";
    int created_timestamp = 0;
    boolean is_active = false;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type PlaceReservationResponse record {|
    boolean success = false;
    string message = "";
    ReservationDetails[] reservations = [];
    float total_amount = 0.0;
    string confirmation_number = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type GetUserProfileRequest record {|
    string user_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type RemoveCarRequest record {|
    string admin_user_id = "";
    string plate = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type UpdateCarRequest record {|
    string admin_user_id = "";
    string plate = "";
    Car updated_car = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddCarResponse record {|
    boolean success = false;
    string message = "";
    string car_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddToCartResponse record {|
    boolean success = false;
    string message = "";
    CartItem cart_item = {};
    int cart_size = 0;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type UpdateCarResponse record {|
    boolean success = false;
    string message = "";
    Car updated_car = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type GetUserProfileResponse record {|
    boolean success = false;
    User user = {};
    string message = "";
    ReservationDetails[] recent_reservations = [];
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type CartItem record {|
    string plate = "";
    string start_date = "";
    string end_date = "";
    float estimated_price = 0.0;
    int rental_days = 0;
    int added_timestamp = 0;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddToCartRequest record {|
    string user_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ListAvailableCarsRequest record {|
    string user_id = "";
    string filter_text = "";
    int filter_year = 0;
    float max_price = 0.0;
    string location = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type SearchCarRequest record {|
    string user_id = "";
    string plate = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddCarRequest record {|
    string admin_user_id = "";
    Car car = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type RemoveCarResponse record {|
    boolean success = false;
    string message = "";
    Car[] remaining_cars = [];
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ViewCartResponse record {|
    boolean success = false;
    CartItem[] cart_items = [];
    float total_estimated_price = 0.0;
    int total_items = 0;
    string message = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type Car record {|
    string plate = "";
    string make = "";
    string model = "";
    int year = 0;
    float daily_price = 0.0;
    int mileage = 0;
    CarStatus status = AVAILABLE;
    string color = "";
    string fuel_type = "";
    int seating_capacity = 0;
    string transmission = "";
    string[] features = [];
    string location = "";
    int created_timestamp = 0;
    int last_updated = 0;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ReservationDetails record {|
    string reservation_id = "";
    string user_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
    float total_price = 0.0;
    int rental_days = 0;
    ReservationStatus status = PENDING;
    int created_timestamp = 0;
    int last_updated = 0;
    string customer_name = "";
    string customer_email = "";
    Car car_details = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type PlaceReservationRequest record {|
    string user_id = "";
    string payment_method = "";
    string special_requests = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type CreateUserRequest record {|
    User user = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type SearchCarResponse record {|
    boolean found = false;
    boolean available = false;
    Car car = {};
    string message = "";
    string[] unavailable_dates = [];
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type CreateUsersResponse record {|
    boolean success = false;
    string message = "";
    int users_created = 0;
    string[] failed_user_ids = [];
|};

public enum CarStatus {
    AVAILABLE, UNAVAILABLE, UNDER_MAINTENANCE, RENTED
}

public enum UserRole {
    CUSTOMER, ADMIN
}

public enum ReservationStatus {
    PENDING, CONFIRMED, COMPLETED, CANCELLED
}
