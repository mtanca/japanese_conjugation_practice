export const APIHelper = {
  composeURLParams: urlParams => {
    const urlKeys = Object.keys(urlParams);
    var params = "";

    if (urlKeys.length !== 0) {
      params =
        "?" +
        urlKeys
          .map(key => `${key}=${urlParams[key]}`)
          .join("&")
          .toString();
    }

    return params;
  },
  callAPI: (url, req) => {
    var remote_url = "http://localhost:4000";
    var url = (process.env.REACT_APP_REMOTE_HOST || remote_url) + url;
    return fetch(url, req)
      .then(res => res.json())
      .then(res => res)
      .catch(err => {
        if (err.error) {
          return err;
        } else {
          return { error: err };
        }
      });
  }
};
