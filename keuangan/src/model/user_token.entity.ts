import { Column, Entity, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from "typeorm";
import { User } from "./user.entity";

@Entity()
export class UserToken {
    
    @PrimaryGeneratedColumn('increment') //it is used to generate primary id, when new data inserted.
    id: number;
    
    @Column()
    fcm_token: string;
    
    @ManyToOne(() => User, (User)=> User.userTokens,{ })
    user: User;

    @Column('date')
    expired_date: string;


}