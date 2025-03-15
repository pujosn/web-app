# Gunakan image Nginx
FROM nginx:alpine


# Salin file HTML ke dalam direktori default Nginx
COPY index.html /usr/share/nginx/html/index.html

# Ekspose port 80 agar bisa diakses dari luar
EXPOSE 80

# Jalankan Nginx
CMD ["nginx", "-g", "daemon off;"]
