# 🏥 MediBook — Hospital Appointment Booking System

A Spring Boot + MySQL + Thymeleaf web application for booking hospital appointments, containerized with Docker and deployed on Kubernetes (kubeadm).

---

## 🛠️ Tech Stack

| Layer       | Technology                        |
|-------------|-----------------------------------|
| Backend     | Spring Boot 3.3.4, Spring Data JPA|
| Frontend    | Thymeleaf, HTML/CSS               |
| Database    | MySQL 8.0                         |
| Container   | Docker (multi-stage build)        |
| Orchestration | Kubernetes (kubeadm)            |

---

## 📦 Project Structure

```
hospital-appointment/
├── src/main/java/com/hospital/
│   ├── entity/          # Patient, Doctor, Appointment
│   ├── repository/      # JPA repositories
│   ├── service/         # Service interfaces + implementations
│   └── controller/      # HomeController, AdminController
├── src/main/resources/
│   ├── templates/       # Thymeleaf HTML pages
│   └── application.properties
├── kube_scripts/
│   ├── db-statefulset-svc.yml   # MySQL StatefulSet + ClusterIP Service
│   ├── app-deploy-svc.yml       # Spring Boot Deployment + NodePort Service
│   └── setup-storage.sh         # Creates hostPath PV for MySQL
├── Dockerfile
├── docker_build_push.sh
└── k8s-deploy.sh
```

---

## 🔑 Roles

| Role    | Login                      | Access                                     |
|---------|----------------------------|--------------------------------------------|
| Admin   | admin / admin              | Dashboard, manage doctors, patients, appointments |
| Patient | registered email/password  | Book appointments, view & cancel own appointments |

---

## ▶️ Running Locally

### Prerequisites
- Java 17, Maven, MySQL running locally

### Steps
```bash
# 1. Update application.properties to point to localhost
spring.datasource.url=jdbc:mysql://localhost:3306/hospitaldb?createDatabaseIfNotExist=true

# 2. Build and run
./mvnw spring-boot:run
```

Access at: **http://localhost:8085**

---

## 🐳 Docker

```bash
# Build image
docker build -t your_dockerhub_username/hospital-appointment:latest .

# Run with Docker (needs MySQL container)
docker network create hospital-net

docker run -d --name mysql-service --network hospital-net \
  -e MYSQL_ROOT_PASSWORD=1234 \
  -e MYSQL_DATABASE=hospitaldb \
  mysql:8.0

docker run -d --name hospital-app --network hospital-net \
  -p 8085:8085 \
  your_dockerhub_username/hospital-appointment:latest

# Or use the build+push script
bash docker_build_push.sh
```

---

## ☸️ Kubernetes (kubeadm)

```bash
# Update image name in kube_scripts/app-deploy-svc.yml first, then:
bash k8s-deploy.sh
```

App will be available at: **http://\<NodeIP\>:30085**

### Useful kubectl commands
```bash
kubectl get pods
kubectl get svc
kubectl logs deployment/hospital-appointment
kubectl describe pod <pod-name>
```

---

## 🗄️ Entities

- **Patient** — fullName, email, phone, gender, age, password
- **Doctor**  — fullName, specialization, qualification, phone, email, availableDays, availableTime
- **Appointment** — date, time, reason, status (PENDING/CONFIRMED/CANCELLED), FK to Patient & Doctor
