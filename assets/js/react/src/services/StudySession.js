import { APIHelper } from "./api";

class StudySession {
  JSON_HEADERS = {
    Accept: "application/json",
    "Content-Type": "application/json"
  };

  start(data) {
    const req = {
      headers: this.JSON_HEADERS,
      method: "POST",
      body: JSON.stringify(data)
    };

    return APIHelper.callAPI(`/study-sessions`, req);
  }

  getSession(sessionId) {
    const req = {
      headers: this.JSON_HEADERS,
      method: "GET"
    };

    return APIHelper.callAPI(`/study-sessions/${sessionId}/details`, req);
  }

  update(sessionId, data) {
    const req = {
      headers: this.JSON_HEADERS,
      method: "PUT",
      body: JSON.stringify(data)
    };

    console.log(req.body);

    return APIHelper.callAPI(`/study-sessions/${sessionId}`, req);
  }
}

export const StudySessionService = new StudySession();
