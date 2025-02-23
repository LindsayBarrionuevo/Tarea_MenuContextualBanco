package com.example.crud_mysql_service.controllers;
import java.sql.Timestamp;
import java.util.Random;

import com.example.crud_mysql_service.models.User;
import com.example.crud_mysql_service.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
//RequestMapping,GetMap..,PutMap..,DeleteMap.. define las rutas de la APIRest
//@CrossOrigin(origins = "http://localhost:58381")
@CrossOrigin(origins = "*") // Permitir desde cualquier origen (prueba en desarrollo)
@RestController
@RequestMapping("api/users")
public class UserController {
    //Inyeccion de servicio: Inyecta el servicio en el controlador para que se pueda acceder a sus metodos.
    @Autowired
    private UserService userService;

    private final Random random = new Random();

    @GetMapping
    public List<User> getAllUsers() {
        return userService.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        User user = (User) userService.getUserById(id);
        if (user != null) {
            return ResponseEntity.ok(user);
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        String accountNumber = generateAccountNumber();

        user.setAccountNumber(accountNumber);

        if (user.getBalance() == null) {
            user.setBalance(10.0);
        }
//Crear tarjeta automaticamente

        if (user.getCreatedAt() == null) {
            user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        }

        return userService.saveUser(user);
    }

    // Método para generar un número de cuenta aleatorio de 11 dígitos
    private String generateAccountNumber() {
        Random random = new Random();
        StringBuilder accountNumber = new StringBuilder();

        for (int i = 0; i < 11; i++) {
            accountNumber.append(random.nextInt(10));
        }

        return accountNumber.toString();
    }

    @PutMapping("/{id}")
    public User updateUser(@RequestBody User user,@PathVariable Long id) {
        return userService.updateUser(id, user);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<User> deleteUser(@PathVariable Long id) {
        User user = (User) userService.getUserById(id);
        if (user != null) {
            userService.deleteUser(id);
            return ResponseEntity.ok(user);
        }
        return ResponseEntity.notFound().build();
    }


}
