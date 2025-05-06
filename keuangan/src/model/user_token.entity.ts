import { Column, Entity, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from "typeorm";
import { User } from "./user.entity";

@Entity()
export class UserToken {
    
    @PrimaryGeneratedColumn('increment', {type:'bigint',unsigned:true}) //it is used to generate primary id, when new data inserted.
    id: number;
    
    @Column({ unique:true })
    fcm_token: string;
    
    @ManyToOne(() => User, (User)=> User.userTokens,{ })
    user: User;

    @UpdateDateColumn()
    expired_date: string;


}