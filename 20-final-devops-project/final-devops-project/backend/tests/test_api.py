def test_health_and_readiness(client):
    assert client.get("/health").json()["status"] == "healthy"
    assert client.get("/ready").json()["database"] == "connected"


def test_create_release(client, release_payload):
    response = client.post("/api/releases", json=release_payload)
    assert response.status_code == 201
    assert response.json()["service"] == "checkout-api"
    assert response.json()["id"] == 1


def test_list_and_get_release(client, release_payload):
    created = client.post("/api/releases", json=release_payload).json()
    assert client.get("/api/releases").json() == [created]
    assert client.get(f"/api/releases/{created['id']}").json() == created


def test_update_release(client, release_payload):
    release_id = client.post("/api/releases", json=release_payload).json()["id"]
    release_payload.update({"status": "healthy", "notes": "Verification passed"})
    response = client.put(f"/api/releases/{release_id}", json=release_payload)
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_delete_release(client, release_payload):
    release_id = client.post("/api/releases", json=release_payload).json()["id"]
    assert client.delete(f"/api/releases/{release_id}").status_code == 204
    assert client.get(f"/api/releases/{release_id}").status_code == 404


def test_stats_aggregate_statuses(client, release_payload):
    client.post("/api/releases", json=release_payload)
    release_payload.update({"service": "catalog-api", "status": "healthy"})
    client.post("/api/releases", json=release_payload)
    assert client.get("/api/releases/stats").json() == {
        "total": 2,
        "healthy": 1,
        "deploying": 1,
        "failed": 0,
    }


def test_validation_and_missing_release(client, release_payload):
    release_payload["environment"] = "moon"
    assert client.post("/api/releases", json=release_payload).status_code == 422
    assert client.get("/api/releases/999").status_code == 404


def test_prometheus_metrics(client):
    client.get("/health")
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "release_tracker_http_requests_total" in response.text
