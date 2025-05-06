import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm"
import { User } from "./user.entity"
export enum RoleType {
    User = 'user',
    Admin = 'admin',
}

@Entity()
export class Role {
    @PrimaryGeneratedColumn()
    id: number

    @Column()
    role_name: string
    
    @OneToMany(() => User, (user) => user.role)
    users: User[]
}