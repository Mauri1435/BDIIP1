package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}

	@GetMapping("/hello")
    public String hello(@RequestParam(value = "name", defaultValue = "World") String name) {
      return String.format("Hello %s!", name);
    }

	@Controller
	public class LoginController {
	
		@GetMapping("/login")
		public String login() {
			return "login"; // Devuelve el nombre de la vista para la página de inicio de sesión (login.html)
		}
	}

	@Configuration
	@EnableWebSecurity
	public class SecSecurityConfig{
		@Bean
		public InMemoryUserDetalisManager  userDetailsService() throws Exception {
			UserDetails user1 = User.withUsername("user1")
            .password(passwordEncoder().encode("user1Pass"))
            .roles("USER")
            .build();
        	UserDetails user2 = User.withUsername("user2")
        	    .password(passwordEncoder().encode("user2Pass"))
        	    .roles("USER")
        	    .build();
        	UserDetails admin = User.withUsername("admin")
        	    .password(passwordEncoder().encode("adminPass"))
        	    .roles("ADMIN")
        	    .build();
        	return new InMemoryUserDetailsManager(user1, user2, admin);
			
		@Bean 
		public PasswordEncoder passwordEncoder() { 
			return new BCryptPasswordEncoder(); 
		}
		
		@Bean
		public SecurityFilterChain filterChain(HttpSecurity http) throws Exception{
			http.csrf()
            .disable()
            .authorizeRequests()
            .antMatchers("/admin/**")
            .hasRole("ADMIN")
            .antMatchers("/anonymous*")
            .anonymous()
            .antMatchers("/login*")
            .permitAll()
            .anyRequest()
            .authenticated()
            .and()
            .formLogin()
      		.loginPage("/login.html")
      		.loginProcessingUrl("/login_processing")
      		.defaultSuccessUrl("/homepage.html", true)
      		.failureUrl("/login.html?error=true")
      		.failureHandler(authenticationFailureHandler())
      		.and()
      		.logout()
      		.logoutUrl("/logout")
      		.deleteCookies("JSESSIONID")
      		.logoutSuccessHandler(logoutSuccessHandler());
      		return http.build();
		}
	}



}
