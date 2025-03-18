package com.example.crud_mysql_service.repositories;

import com.example.crud_mysql_service.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
//Extends JpaRepositorio con la entidad principal y el tipo de dato del ID
public interface UserRepository extends JpaRepository<User,Long> {
}
