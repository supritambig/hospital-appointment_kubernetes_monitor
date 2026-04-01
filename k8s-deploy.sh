#!/bin/bash

set -e

BASE_PATH="kube_scripts"
STORAGE_FLAG_FILE="$BASE_PATH/.storage_done"

# ================================
# Setup Storage (Only Once)
# ================================
setup_storage() {
    if [[ -f "$STORAGE_FLAG_FILE" ]]; then
        echo "✅ Storage already set up, skipping..."
    else
        echo "[1/4] Setting up storage (PersistentVolume)..."
        bash "$BASE_PATH/setup-storage.sh"
        touch "$STORAGE_FLAG_FILE"
        echo "✅ Storage setup completed."
    fi
}

# ================================
# Deploy DB
# ================================
deploy_db() {
    setup_storage
    echo "[2/4] Deploying MySQL StatefulSet and Service..."
    kubectl apply -f "$BASE_PATH/db-statefulset-svc.yml"

    echo "Waiting for MySQL to be ready..."
    kubectl rollout status statefulset/mysql --timeout=120s

    echo "✅ MySQL deployed successfully."
}

# ================================
# Deploy App
# ================================
deploy_app() {
    echo "[3/4] Deploying Spring Boot App..."
    kubectl apply -f "$BASE_PATH/app-deploy-svc.yml"

    echo "[4/4] Waiting for App Deployment..."
    kubectl rollout status deployment/hospital-appointment --timeout=120s

    echo "================================================"
    echo "✅ Deployment Complete!"
    echo "Access: http://<NodeIP>:30085"
    echo "Admin:  admin / admin"
    echo "================================================"

    kubectl get pods
    kubectl get svc
}

# ================================
# Remove DB
# ================================
remove_db() {
    echo "🔹 Removing MySQL..."
    kubectl delete -f "$BASE_PATH/db-statefulset-svc.yml" --ignore-not-found
    echo "✅ MySQL removed."
}

# ================================
# Remove App
# ================================
remove_app() {
    echo "🔹 Removing App..."
    kubectl delete -f "$BASE_PATH/app-deploy-svc.yml" --ignore-not-found
    echo "✅ App removed."
}

# ================================
# Menu
# ================================
show_menu() {
    echo ""
    echo "===== Hospital App Kubernetes Menu ====="
    echo "1) Deploy DB"
    echo "2) Deploy App"
    echo "3) Remove DB"
    echo "4) Remove App"
    echo "5) Full Deploy (DB + App)"
    echo "6) Exit"
    echo "========================================"

    read -p "Choose option [1-6]: " choice

    case "$choice" in
        1) deploy_db ;;
        2) deploy_app ;;
        3) remove_db ;;
        4) remove_app ;;
        5) deploy_db && deploy_app ;;
        6) exit 0 ;;
        *) echo "❌ Invalid option" ;;
    esac
}

# ================================
# Loop
# ================================
while true; do
    show_menu
done