public with sharing class ConnectSpotify {

    public static void makeConnectCallout() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://accounts.spotify.com/api/token');
            request.setMethod('POST');
            SpotifyCredentials__c credentials = SpotifyCredentials__c.getOrgDefaults();
            String body = 'grant_type=client_credentials&' +
                    'client_id=' + credentials.ClientId__c +
                    '&client_secret=' + credentials.ClientSecret__c;
            request.setBody(body);
            HttpResponse response = http.send(request);
            ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
            Cache.Org.getPartition('local.myCache').put('token', responseWrapper.access_token);
            Cache.Org.getPartition('local.myCache').put('tokenExpires', Datetime.now().addHours(1).format());
        } catch (Exception e) {
            e.getMessage();
        }
    }

    public static ArtistWrapper searchArtistsCallout(String searchingName) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://api.spotify.com/v1/search?q=' + searchingName.replace(' ', '%20') + '&type=artist');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        ArtistWrapper results = (ArtistWrapper) JSON.deserialize(response.getBody(), ArtistWrapper.class);
        return ArtistsService.convertNoimage(results);
    }

    public static ArtistWrapper foundArtistCallout(String endpoint) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        ArtistWrapper results = (ArtistWrapper) JSON.deserialize(response.getBody(), ArtistWrapper.class);
        return ArtistsService.convertNoimage(results);
    }

    public static TrackWrapper foundTrackCallout(String endpoint) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        TrackWrapper results = (TrackWrapper) JSON.deserialize(response.getBody(), TrackWrapper.class);
        return results;
    }

    public static ArtistWrapper foundLastArtistCallout(String endpoint, Integer offset) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint.substringBeforeLast('=').substringBeforeLast('=')+'=' + offset +'&limit=20');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        ArtistWrapper results = (ArtistWrapper) JSON.deserialize(response.getBody(), ArtistWrapper.class);
        return ArtistsService.convertNoimage(results);
    }

    public static TrackWrapper foundLastTrackCallout(String endpoint, Integer offset) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint.substringBeforeLast('=').substringBeforeLast('=')+'=' + offset +'&limit=20');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        TrackWrapper results = (TrackWrapper) JSON.deserialize(response.getBody(), TrackWrapper.class);
        return results;
    }

    public static TrackWrapper searchTracksCallout(String searchingName) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://api.spotify.com/v1/search?q=' + searchingName.replace(' ', '%20') + '&type=track');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        TrackWrapper results = (TrackWrapper) JSON.deserialize(response.getBody(), TrackWrapper.class);
        return results;
    }

    public static SingleArtistTrackWrapper getArtistsTracks(String artistId) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://api.spotify.com/v1/artists/' + artistId + '/top-tracks?market=PL');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        SingleArtistTrackWrapper results = (SingleArtistTrackWrapper) JSON.deserialize(response.getBody(), SingleArtistTrackWrapper.class);
        return results;
    }

    public static SingleTrackWrapper getTrack(String trackId) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://api.spotify.com/v1/tracks/'+ trackId);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        SingleTrackWrapper results = (SingleTrackWrapper) JSON.deserialize(response.getBody(), SingleTrackWrapper.class);
        return results;
    }

    public static SingleArtistWrapper getArtist(String artistId) {
        isConnectNeeded();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://api.spotify.com/v1/artists/'+ artistId);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        HttpResponse response = http.send(request);
        SingleArtistWrapper results = (SingleArtistWrapper) JSON.deserialize(response.getBody(), SingleArtistWrapper.class);
        return ArtistsService.convertNoimage(results);
    }

    private static void isConnectNeeded() {
        if (Cache.Org.getPartition('local.myCache').get('tokenExpires') == null
                || DateTime.parse((String) Cache.Org.getPartition('local.myCache').get('tokenExpires')) < Datetime.now()) {
            makeConnectCallout();
        }
    }

    class ResponseWrapper {
        public String access_token;
    }

}